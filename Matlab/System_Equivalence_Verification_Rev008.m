clear all

%%% This is a scaled back version of the system equivalence for the IIR
%%% filter with a non repeating pn code

USAMPR = 2;

%%% Filter information
a1 = [1, -0.0183, 0.8665]; a2 = [1, -0.1458, 0.6341]; a3 = [1, -0.3545, 0.4290];
a4 = [1, -0.5802, 0.2583]; a5 = [1, -0.7321, 0.1558];
b1 = [1 2 1];
sos = [b1, a1; b1, a2; b1, a3; b1, a4; b1, a5];
k = 8.2924e-4; kk = power(k,1/5);

%%% Alphabet Information
complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';
Prefix = randsrc(1, 3 * size(sos,1),complex_mapping,3);

%%% Transmit Information
PN_Length = 2^17; symbol_pn_size = 2^8;
NSYMBOLS = PN_Length / symbol_pn_size;

%%% Sequence Generation
c = randsrc(1,PN_Length,complex_mapping,123); s = randsrc(1,NSYMBOLS,complex_mapping,233);

%%% Do this for a direct comparison of the repeat code version to the non
%%% repeating code version
c = repmat(randsrc(1,symbol_pn_size,complex_mapping,123), 1, NSYMBOLS);

cx = []; n = 0;
while (n < length(s))
    indicies = 1 + (n*symbol_pn_size):(n+1)*symbol_pn_size;
    cx = [cx (s(n + 1) * c(indicies))];
    n = n + 1;
end

% Transmit Filtering
cxup = upsample(cx,USAMPR);
sout = [Prefix cxup Prefix];

for i = 1:1:size(sos, 1)
    sout = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),sout);
end

%Normalize
sout = sout ./ max(abs(sout));

% Receive Filtering
bbdata_rx = fliplr(sout);
for i = 1:1:size(sos, 1)
    bbdata_rx = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),bbdata_rx);
end
bbdata_rx = fliplr(bbdata_rx);

ind = 0;
r = 0;
hold off
plot((s))
hold on
while sum(abs(s-r)) > 1
    f = downsample(bbdata_rx(1+ind:end-ind), USAMPR);

    n = 0;
    r = [];
    while (n < length(s))
        indicies = 1 + (n*symbol_pn_size):(n+1)*symbol_pn_size;
        r = [r (f(indicies) * c(indicies)')];
        n = n + 1;
    end
    r = r / length(c);
    r = r ./ max(abs(r));
    ind = ind + 1;
    plot((r))
    sum(abs(s-r))
    ind
end

g = upsample(c'.', USAMPR); %Mathematically correct but has different ind value than other way
for i = 1:1:size(sos, 1)
    g = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),g);
end

ind = 0;
r2 = 0;
hold off
plot((s))
hold on
while sum(abs(s-r2)) > 0.5
    f2 = sout(1+ind:end-ind);

    n = 0;
    r2 = [];
    while (n < length(s))
        indicies = 1 + (n*symbol_pn_size*USAMPR):(n+1)*symbol_pn_size*USAMPR;
        r2 = [r2 (f2(indicies) * g(indicies).')];
        n = n + 1;
    end
    r2 = r2 / length(g);
    r2 = r2 ./ max(abs(r2));
    ind = ind + 1;
    plot((r2))
    sum(abs(s-r2))
    ind
end

ind = length(Prefix);
f2 = sout(1+ind:end-ind);
n = 0;
r2 = [];
while (n < length(s))
    indicies = 1 + (n*symbol_pn_size*USAMPR):(n+1)*symbol_pn_size*USAMPR;
    r2 = [r2 (f2(indicies) * g(indicies).')];
    n = n + 1;
end
r2 = r2 / length(g);
r2 = r2 ./ max(abs(r2));
plot((r2))
sum(abs(s-r2))