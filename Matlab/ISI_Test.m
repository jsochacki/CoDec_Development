clear all

ERROR_LIMIT=100;

complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';

NSYMBOLS=2*1024;

USAMPR = 2;

a1 = [1, -0.0183, 0.8665];
a2 = [1, -0.1458, 0.6341];
a3 = [1, -0.3545, 0.4290];
a4 = [1, -0.5802, 0.2583];
a5 = [1, -0.7321, 0.1558];

b1 = [1 2 1]; % = b2 = b3 = b4 = b5

sos = [b1, a1; b1, a2; b1, a3; b1, a4; b1, a5];
sosmf = [fliplr(b1), a1(1) a1(3) a1(2); ...
         fliplr(b1), a2(1) a2(3) a2(2); ...
         fliplr(b1), a3(1) a3(3) a3(2); ...
         fliplr(b1), a4(1) a4(3) a4(2); ...
         fliplr(b1), a5(1) a5(3) a5(2)];

k = 8.2924e-4;

s=randsrc(1,NSYMBOLS,complex_mapping);
unmapped_symbol_stream=s;
Perfect_Soft_Decision_Decoding=s;

PS=complex_mapping;
DATA_GOOD_AT_NP=(length(PS)*USAMPR)+(length(btot)-1)/2;
%unmapped_symbol_stream=[zeros(1,512) 1 zeros(1,512)]; %[PS unmapped_symbol_stream PS];
unmapped_symbol_stream=[PS unmapped_symbol_stream PS];

sup=upsample(unmapped_symbol_stream,USAMPR);

kk = power(k,1/5);
sout = sup;
for i = 1:1:size(sos, 1)
    sout = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),sout);
end

% for i = 1:1:size(sos, 1)
%     sout = conv(kk*sos(i, 1:1:3), sout);
%     sout = deconv(sout, sos(i, 4:1:6));
% end

plot(20*log10(abs(fftshift(fft(sout, length(sout))))))

%Normalize
sout=sout./max(abs(sout));

bbdata_rx = fliplr(sout);
for i = 1:1:size(sos, 1)
    bbdata_rx = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),bbdata_rx);
end

r1 = filter(btot, atot, [zeros(1,512) 1 zeros(1,512)]);
plot(20*log10(abs(fftshift(fft(r1, length(r1))))))
r2 = filter(btot, atot, r1);
plot(20*log10(abs(fftshift(fft(r2, length(r2))))))

plot(20*log10(abs(fftshift(fft(bbdata_rx, length(bbdata_rx))))))
plot(bbdata_rx, 'bo')
n=29
plot(downsample(bbdata_rx(1+n:end-n),2), 'bo')

%Align the processed vector
expected_bbdata_rx=circ_shift_2_to_1(sup,expected_bbdata_rx);
bbdata_rx=circ_shift_2_to_1(sup,bbdata_rx);

%Chop off ring up and down to pretend it is continuous signal
%Chop needs to be dynamic so it changes with the length of h and the QMF
%coeffs
expected_bbdata_rx=expected_bbdata_rx(1:1:(end-(length(expected_bbdata_rx)-length(sup))));
bbdata_rx=bbdata_rx(1:1:length(expected_bbdata_rx));
templ=length(expected_bbdata_rx);
%Chop off ring up and down to pretend it is continuous signal

bbdata_rx=downsample(bbdata_rx./max(abs(bbdata_rx)),USAMPR);
expected_bbdata_rx=downsample(expected_bbdata_rx./max(abs(expected_bbdata_rx)),USAMPR);

%GetBBdata befor you chop ring off for power measurements

%Remove pilot symbols
bbdata_rx=bbdata_rx((1+length(PS)):1:(end-length(PS)));
expected_bbdata_rx=expected_bbdata_rx((1+length(PS)):1:(end-length(PS)));

%Normalize
bbdata_rx=bbdata_rx./max(abs(bbdata_rx));
expected_bbdata_rx=expected_bbdata_rx./max(abs(expected_bbdata_rx));

%Decode
%TO GET PROPER BER YOU MUST DO WHAT IS BELOW!!!!!!!
expected_decode_mapping=(mean(abs(expected_bbdata_rx))).*complex_mapping./max(abs(complex_mapping));
decode_mapping=(mean(abs(bbdata_rx))).*complex_mapping./max(abs(complex_mapping));
rescale=mean(abs(expected_decode_mapping))/mean(abs(decode_mapping));
[decoded_complex_stream]=AWGN_maximum_likelyhood_decoder(bbdata_rx,decode_mapping,complex_mapping);
decoded_binary_word_stream=custom_mapper(decoded_complex_stream.',complex_mapping,Binary_Alphabet);
[expected_unmapped_symbol_stream]=AWGN_maximum_likelyhood_decoder(expected_bbdata_rx,expected_decode_mapping,complex_mapping);
expected_decoded_binary_word_stream=custom_mapper(expected_unmapped_symbol_stream.',complex_mapping,Binary_Alphabet);
if length(decoded_complex_stream)>length(expected_unmapped_symbol_stream)
    Bit_Errors=sum(sum(abs(expected_decoded_binary_word_stream-decoded_binary_word_stream(1:1:length(expected_unmapped_symbol_stream),:))));
elseif length(decoded_complex_stream)<length(expected_unmapped_symbol_stream)
    Bit_Errors=sum(sum(abs(expected_decoded_binary_word_stream(1:1:length(decoded_complex_stream),:)-decoded_binary_word_stream)));
else
    Bit_Errors=sum(sum(abs(expected_decoded_binary_word_stream-decoded_binary_word_stream)));
end
BER=Bit_Errors/(size(expected_decoded_binary_word_stream,1)*size(expected_decoded_binary_word_stream,2));
[BER Bit_Errors]

ERRORS=ERRORS+Bit_Errors;
BERCUR=ERRORS/(ii*NSYMBOLS*BITS_PER_WORD);
[BERCUR ERRORS]
if JUMP
    ERRORS=ERROR_LIMIT;
    JUMP=0; 
end


figure(1)
plot(OBO_FROM_P1DB_vec,([mean(EBNOVEC{i}{1}(1:end/2)) mean(EBNOVEC{i}{2}(1:end/2)) mean(EBNOVEC{i}{3}(1:end/2)) mean(EBNOVEC{i}{4}(1:end/2)) mean(EBNOVEC{i}{5}(1:end/2)) mean(EBNOVEC{i}{6}(1:end/2))]),'bo-')
hold on
plot(OBO_FROM_P1DB_vec,([mean(EBNOVEC{i}{7}(1:end/2)) mean(EBNOVEC{i}{8}(1:end/2)) mean(EBNOVEC{i}{9}(1:end/2)) mean(EBNOVEC{i}{10}(1:end/2)) mean(EBNOVEC{i}{11}(1:end/2)) mean(EBNOVEC{i}{12}(1:end/2))]),'ro-')
hold off
legend('Hard Decision Decoded','Soft Decision Decoded','location','north')
title(sprintf('Detected Amplitude Distortion Uncoded at %i (dB) EbNo 16 APSK RingRatio=3.15',EbNo_vector(i)))
ylabel('Amplitude Distortion (Volts)'), xlabel('PA OBO (dB)')
grid on
