
% variables_3dB = {'sos_3dB', 'fos_3dB', 'k_3dB'};
% 
% test_variables = load('filter_coefficients.mat',variables_3dB{:})
% 
% %Access is done dynamically in the following manner
% test_variables.(variables_3dB{1})
clear all

MODCOD = 1;

[Complex_Alphabet ...
 Binary_Alphabet ...
 Decimal_Alphabet ...
 BITS_PER_WORD] ...
     = dvbs2_Constellations(MODCOD);
            
transmitted_binary_stream = randsrc(1,512, [1 0]);
[word_stream] = binary_stream_to_binary_word_stream( ...
                          transmitted_binary_stream, ...
                          BITS_PER_WORD);

[decimal_stream] = binary_stream_to_decimal_stream( ...
                         transmitted_binary_stream, ...
                         BITS_PER_WORD);

% Pick one
[symbol_stream]=one_to_one_mappper(word_stream,Binary_Alphabet,Complex_Alphabet);
[symbol_stream]=one_to_one_mappper(decimal_stream,Decimal_Alphabet,Complex_Alphabet);

[received_binary_stream] = decimal_stream_to_binary_stream( ...
                                            decimal_stream, ...
                                            BITS_PER_WORD);

sum(transmitted_binary_stream == received_binary_stream)


M = 4; % Alphabet size
EbN0_min=0;EbN0_max=10;step=0.1;
SNR=[];SER=[];
for EbN0 = EbN0_min:step:EbN0_max
    SNR_dB=EbN0 + 3; %for QPSK Eb/N0=0.5*Es/N0=0.5*SNR
    if EbN0 > 8
        NumberOfSymbols = 10000000;
    else
        NumberOfSymbols = 1000000;
    end
    x = randint(NumberOfSymbols,1,M);
    y=modulate(modem.qammod(M),x);
    ynoisy = awgn(y,SNR_dB,'measured');
    z=demodulate(modem.qamdemod(M),ynoisy);
    [num,rt]= symerr(x,z);
    SNR=[SNR EbN0];
    SER=[SER rt];
end;
semilogy(SNR,SER);grid;title('Symbol error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)');ylabel('SER')

EbN0 = EbN0_min:step:EbN0_max;
matlab_BER = berawgn(EbN0, 'psk', M, 'nondiff');

hold off
figure(2)
semilogy(EbN0,matlab_BER);grid;title('Bit error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)');ylabel('BER')