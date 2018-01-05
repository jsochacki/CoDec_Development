clear all

PLOT=0;

USAMPR = 2;

%%% Filter information
a1 = [1, -0.0183, 0.8665];
a2 = [1, -0.1458, 0.6341];
a3 = [1, -0.3545, 0.4290];
a4 = [1, -0.5802, 0.2583];
a5 = [1, -0.7321, 0.1558];

b1 = [1 2 1]; % = b2 = b3 = b4 = b5

sos = [b1, a1; b1, a2; b1, a3; b1, a4; b1, a5];

k = 8.2924e-4;

%%% Alphabet Information
complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';

Prefix = randsrc(1, 3 * size(sos,1),complex_mapping,3);

%%% Transmit Information
PN_Length = 512;
NSYMBOLS=32;

%%% Sequence Generation
c = randsrc(1,PN_Length,complex_mapping,123);
s = randsrc(1,NSYMBOLS,complex_mapping,233);

%%% Zero Order Holder
% x = repelem(s,length(c));

%%% Transmit Spreading
% cx = [];
% n = 0;
% while (n < length(x))
%     cx(n + 1) = x(n + 1) * c(mod(n, length(c)) + 1);
%     n = n + 1;
% end
cx = [];
n = 0;
while (n < length(s))
    cx = [cx (s(n + 1) * c)];
    n = n + 1;
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(cx,'bo')
end

% Transmit Filtering
cxup=upsample(cx,USAMPR);

% h = firrcos(512,0.5,.15,2,'rolloff','sqrt');

kk = power(k,1/5);
sout = [Prefix cxup Prefix];
for i = 1:1:size(sos, 1)
    sout = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),sout);
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(sout,'bo')
    plot(20*log10(abs(fftshift(fft(sout,length(sout))))))
end

%Normalize
sout=sout./max(abs(sout));

% Receive Filtering
bbdata_rx = fliplr(sout);
for i = 1:1:size(sos, 1)
    bbdata_rx = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),bbdata_rx);
end
bbdata_rx = fliplr(bbdata_rx);

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(bbdata_rx,'bo')
    plot(20*log10(abs(fftshift(fft(bbdata_rx,length(bbdata_rx))))))
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    n=((32*512)/2) + 1
    plot(downsample(bbdata_rx(1+n:end-n),2), 'bo')
    plot(downsample(bbdata_rx(1+(length(Prefix)):end),2), 'bo')
end

ind = 0;
r = 0;
hold off
plot((s))
hold on
while sum(abs(s-r)) > 0.05
f = downsample(bbdata_rx(1+ind:end-ind), USAMPR);

n = 0;
r = [];
while (n < length(s))
    r = [r (f(((n * length(c)) + 1):((n + 1) * length(c))) * c')];
    n = n + 1;
end
r = r / length(c);
r = r ./ max(abs(r));
ind = ind + 1;
plot((r))
sum(abs(s-r))
ind
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(r,'bo')
end

%%% Calculate EsNo
EsNo_dB=[]; PERROR_Vector=[]; PREF_Vector=[];

VERROR=[];
VERROR=r-s;
PERROR_Vector=VERROR.*VERROR'.';
PREF_Vector=s.*s'.';

RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);

%%% Calculate EVM
EVM_dB=[];
EVM_dB=10*log10(RMS_PERROR/RMS_PREF);

% g = c'.'; %Mathematically correct but has different ind value than other way
% for i = 1:1:size(sos, 1)
%     g = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),g);
% end
% 
% ind = 0;
% r2 = 0;
% hold off
% plot((s))
% hold on
% while sum(abs(s-r2)) > 1
% f2 = downsample(sout(1+ind:end-ind), USAMPR);
% 
% n = 0;
% r2 = [];
% while (n < length(s))
%     r2 = [r2 (f2(((n * length(g)) + 1):((n + 1) * length(g))) * g.')];
%     n = n + 1;
% end
% r2 = r2 / length(g);
% r2 = r2 ./ max(abs(r2));
% ind = ind + 1;
% plot((r2))
% sum(abs(s-r2))
% ind
% end
% 
% % PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if PLOT
%     plot(r,'bo')
%     hold on
%     plot(r2,'ro')
% end
% 
% %%% Calculate EsNo
% EsNo_dB=[]; PERROR_Vector=[]; PREF_Vector=[];
% 
% VERROR=[];
% VERROR=r2-s;
% PERROR_Vector=VERROR.*VERROR'.';
% PREF_Vector=s.*s'.';
% 
% RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
% RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
% EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);
% 
% %%% Calculate EVM
% EVM_dB=[];
% EVM_dB=10*log10(RMS_PERROR/RMS_PREF);


g = upsample(c'.', USAMPR); %Mathematically correct but has different ind value than other way
for i = 1:1:size(sos, 1)
    g = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),g);
end

ind = 0;
r2 = 0;
hold off
plot((s))
hold on
while sum(abs(s-r2)) > 1
f2 = sout(1+ind:end-ind);

n = 0;
r2 = [];
while (n < length(s))
    r2 = [r2 (f2(((n * length(g)) + 1):((n + 1) * length(g))) * g.')];
    n = n + 1;
end
r2 = r2 / length(g);
r2 = r2 ./ max(abs(r2));
ind = ind + 1;
plot((r2))
sum(abs(s-r2))
ind
end
%%% Note the you don't need to actually downsample as your correlation
%%% compresses the sequence to a single value

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(r,'bo')
    hold on
    plot(r2,'ro')
end

%%% Calculate EsNo
EsNo_dB=[]; PERROR_Vector=[]; PREF_Vector=[];

VERROR=[];
VERROR=r2-s;
PERROR_Vector=VERROR.*VERROR'.';
PREF_Vector=s.*s'.';

RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);

%%% Calculate EVM
EVM_dB=[];
EVM_dB=10*log10(RMS_PERROR/RMS_PREF);
% 
% %Align the processed vector
% expected_bbdata_rx=circ_shift_2_to_1(cxup,expected_bbdata_rx);
% bbdata_rx=circ_shift_2_to_1(cxup,bbdata_rx);
% 
% %Chop off ring up and down to pretend it is continuous signal
% %Chop needs to be dynamic so it changes with the length of h and the QMF
% %coeffs
% expected_bbdata_rx=expected_bbdata_rx(1:1:(end-(length(expected_bbdata_rx)-length(cxup))));
% bbdata_rx=bbdata_rx(1:1:length(expected_bbdata_rx));
% templ=length(expected_bbdata_rx);
% %Chop off ring up and down to pretend it is continuous signal
% 
% bbdata_rx=downsample(bbdata_rx./max(abs(bbdata_rx)),USAMPR);
% expected_bbdata_rx=downsample(expected_bbdata_rx./max(abs(expected_bbdata_rx)),USAMPR);
% 
% %GetBBdata befor you chop ring off for power measurements
% 
% %Remove pilot symbols
% bbdata_rx=bbdata_rx((1+length(PS)):1:(end-length(PS)));
% expected_bbdata_rx=expected_bbdata_rx((1+length(PS)):1:(end-length(PS)));
% 
% %Normalize
% bbdata_rx=bbdata_rx./max(abs(bbdata_rx));
% expected_bbdata_rx=expected_bbdata_rx./max(abs(expected_bbdata_rx));
% 
% %Decode
% %TO GET PROPER BER YOU MUST DO WHAT IS BELOW!!!!!!!
% expected_decode_mapping=(mean(abs(expected_bbdata_rx))).*complex_mapping./max(abs(complex_mapping));
% decode_mapping=(mean(abs(bbdata_rx))).*complex_mapping./max(abs(complex_mapping));
% rescale=mean(abs(expected_decode_mapping))/mean(abs(decode_mapping));
% [decoded_complex_stream]=AWGN_maximum_likelyhood_decoder(bbdata_rx,decode_mapping,complex_mapping);
% decoded_binary_word_stream=custom_mapper(decoded_complex_stream.',complex_mapping,Binary_Alphabet);
% [expected_unmapped_symbol_stream]=AWGN_maximum_likelyhood_decoder(expected_bbdata_rx,expected_decode_mapping,complex_mapping);
% expected_decoded_binary_word_stream=custom_mapper(expected_unmapped_symbol_stream.',complex_mapping,Binary_Alphabet);
% if length(decoded_complex_stream)>length(expected_unmapped_symbol_stream)
%     Bit_Errors=sum(sum(abs(expected_decoded_binary_word_stream-decoded_binary_word_stream(1:1:length(expected_unmapped_symbol_stream),:))));
% elseif length(decoded_complex_stream)<length(expected_unmapped_symbol_stream)
%     Bit_Errors=sum(sum(abs(expected_decoded_binary_word_stream(1:1:length(decoded_complex_stream),:)-decoded_binary_word_stream)));
% else
%     Bit_Errors=sum(sum(abs(expected_decoded_binary_word_stream-decoded_binary_word_stream)));
% end
% BER=Bit_Errors/(size(expected_decoded_binary_word_stream,1)*size(expected_decoded_binary_word_stream,2));
% [BER Bit_Errors]
% 
% ERRORS=ERRORS+Bit_Errors;
% BERCUR=ERRORS/(ii*NSYMBOLS*BITS_PER_WORD);
% [BERCUR ERRORS]
% if JUMP
%     ERRORS=ERROR_LIMIT;
%     JUMP=0; 
% end
% 
% 
% figure(1)
% plot(OBO_FROM_P1DB_vec,([mean(EBNOVEC{i}{1}(1:end/2)) mean(EBNOVEC{i}{2}(1:end/2)) mean(EBNOVEC{i}{3}(1:end/2)) mean(EBNOVEC{i}{4}(1:end/2)) mean(EBNOVEC{i}{5}(1:end/2)) mean(EBNOVEC{i}{6}(1:end/2))]),'bo-')
% hold on
% plot(OBO_FROM_P1DB_vec,([mean(EBNOVEC{i}{7}(1:end/2)) mean(EBNOVEC{i}{8}(1:end/2)) mean(EBNOVEC{i}{9}(1:end/2)) mean(EBNOVEC{i}{10}(1:end/2)) mean(EBNOVEC{i}{11}(1:end/2)) mean(EBNOVEC{i}{12}(1:end/2))]),'ro-')
% hold off
% legend('Hard Decision Decoded','Soft Decision Decoded','location','north')
% title(sprintf('Detected Amplitude Distortion Uncoded at %i (dB) EbNo 16 APSK RingRatio=3.15',EbNo_vector(i)))
% ylabel('Amplitude Distortion (Volts)'), xlabel('PA OBO (dB)')
% grid on
