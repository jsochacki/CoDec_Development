clear all

%%% This is a scaled back version of the system equivalence for the IIR
%%% filter with a non repeating pn code but constant data to reduce ISI
%%% due to filter impulse response ring out.  There will still be ISI as
%%% the pn code is not repeating

USAMPR = 2;

%SRRC Filter for Comparison
NSYMBOLS_LONG_FILTER = 120; ORDER = USAMPR * NSYMBOLS_LONG_FILTER;
ROLLOFF = 0.1; SYMBOL_RATE = 1; Fc = SYMBOL_RATE / 2;
h = firrcos(ORDER, Fc, ROLLOFF, USAMPR, 'rolloff', 'sqrt');

%IIR Filter
BITS_PER_WORD = 2; test_number = 1;
test_vector = test_vectors_top_level(test_number);
test_variables = load('filter_coefficients.mat', test_vector{1}{:});
test_variables.pn_length = test_vector{2};
stream_pn_length = BITS_PER_WORD * test_variables.pn_length;
test_variables.EbNo = test_vector{3};
test_variables.BER = test_vector{4};
%Access is done dynamically in the following manner
sos = test_variables.(test_vector{1}{1});
fos = test_variables.(test_vector{1}{2});
k = test_variables.(test_vector{1}{3});

%%% Alphabet Information
complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';
Prefix = randsrc(1, 2 * length(h),complex_mapping,3);

%%% Transmit Information
PN_Length = 2^17; symbol_pn_size = 2^8;
NSYMBOLS = PN_Length / symbol_pn_size;

%%% Sequence Generation
c = randsrc(1,PN_Length,complex_mapping,123);
s = complex_mapping(1) * ones(1, NSYMBOLS); %%% randsrc(1,NSYMBOLS,complex_mapping,233);

%%% Do this for a direct comparison of the repeat code version to the non
%%% repeating code version
%c = repmat(randsrc(1,symbol_pn_size,complex_mapping,123), 1, NSYMBOLS);

cx = []; n = 0;
while (n < length(s))
    indicies = 1 + (n*symbol_pn_size):(n+1)*symbol_pn_size;
    cx = [cx (s(n + 1) * c(indicies))];
    n = n + 1;
end

%Transmit Filtering
cx = [Prefix cx Prefix];
cxup = upsample(cx,USAMPR);

%Filter
sout_srrc = conv(h, cxup);
sout_iir = custom_filter(cxup, sos, fos, k);

%Normalize
sout_srrc = sout_srrc ./ max(abs(sout_srrc));
sout_iir = sout_iir ./ max(abs(sout_iir));

%Receive Filtering
bbdata_rx_srrc = conv(fliplr(h), sout_srrc);
bbdata_rx_iir = fliplr(sout_iir);        
bbdata_rx_iir = custom_filter(bbdata_rx_iir, sos, fos, k);
bbdata_rx_iir = fliplr(bbdata_rx_iir);

hold off
plot((s))
hold on

ind = length(Prefix) * USAMPR;
f = downsample(bbdata_rx_iir(1+ind:end-ind), USAMPR);
n = 0; r = [];
while (n < length(s))
    indicies = 1 + (n*symbol_pn_size):(n+1)*symbol_pn_size;
    r = [r (f(indicies) * c(indicies)')];
    n = n + 1;
end
r = r / symbol_pn_size;
r = AGC2(r, 1, 0);
plot((r))
sum(abs(s-r))
[EsNo_dB EVM_dB] = EsNo_and_EVM(s, r)

hold off
plot((s))
hold on

ind = (length(Prefix) * USAMPR) + (((length(h) - 1) / 2) * 2);
f2 = downsample(bbdata_rx_srrc(1+ind:end-ind), USAMPR);
n = 0; r2 = [];
while (n < length(s))
    indicies = 1 + (n*symbol_pn_size):(n+1)*symbol_pn_size;
    r2 = [r2 (f2(indicies) * c(indicies)')];
    n = n + 1;
end
r2 = r2 / symbol_pn_size;
r2 = AGC2(r2, 1, 0);
plot((r2))
sum(abs(s-r2))
[EsNo_dB EVM_dB] = EsNo_and_EVM(s, r2)

hold off
plot((s))
hold on

g = upsample(c'.', USAMPR);
g = custom_filter(g, sos, fos, k);

ind = (length(Prefix) * USAMPR);
f3 = sout_iir(1+ind:end-ind);
n = 0; r3 = [];
while (n < length(s))
    indicies = (1 + (n * (symbol_pn_size * USAMPR))) ...
               :((n+1) * (symbol_pn_size * USAMPR));
    r3 = [r3 (f3(indicies) * g(indicies).')];
    n = n + 1;
end
r3 = r3 / symbol_pn_size;
r3 = AGC2(r3, 1, 0);
plot((r3))
sum(abs(s-r3))
[EsNo_dB EVM_dB] = EsNo_and_EVM(s, r3)


hold off
plot((s))
hold on

g = upsample(c'.', USAMPR);
g = conv(fliplr(h), g);
%%%%THE LENGTH OF G EXPANDS HERE SO YOU NEED TO TREAT
%%%%THAT PROPERLY BELOW by offsetting the indicies of g that you use to be
%%%%the ones that are valid only and not in the ringud of the filter or you
%%%%can just throw away the ring up and ring down
g = g(1 + ((length(h) - 1) / 2):end-((length(h) - 1) / 2));
ind = (length(Prefix) * USAMPR) + (((length(h) - 1) / 2));
f4 = sout_srrc(1+ind:end-ind);
n = 0; r4 = [];
while (n < length(s))
    indicies = (1 + (n * (symbol_pn_size * USAMPR))) ...
               :((n+1) * (symbol_pn_size * USAMPR));
    r4 = [r4 (f4(indicies) * g(indicies).')];
    n = n + 1;
end
r4 = r4 / symbol_pn_size;
r4 = AGC2(r4, 1, 0);
plot((r4))
sum(abs(s-r4))
[EsNo_dB EVM_dB] = EsNo_and_EVM(s, r4)
