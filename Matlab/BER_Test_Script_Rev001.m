
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

M = power(2, BITS_PER_WORD); % Alphabet size

EbN0_min=0; EbN0_max=10; step=0.1;
SNR=[]; BER=[];
for EbN0 = EbN0_min:step:EbN0_max
    EbN0
    ERRORS = 0; SYMBOLS = 0;
    if EbN0 < 3
        ERRORLIMIT = 1000;
        NumberOfSymbols = 2^14;
    elseif (EbN0 >= 3) & (EbN0 < 6)
        ERRORLIMIT = 700;
        NumberOfSymbols = 2^15;
    elseif (EbN0 >= 6) & (EbN0 < 7)
        ERRORLIMIT = 500;
        NumberOfSymbols = 2^16;
    elseif (EbN0 >= 7) & (EbN0 < 8)
        ERRORLIMIT = 200;
        NumberOfSymbols = 2^17;
    else
        ERRORLIMIT = 50;
        NumberOfSymbols = 2^18;
    end
    while ERRORS < ERRORLIMIT
        ERRORS
        SNR_dB=EbN0 + 3; %for QPSK Eb/N0=0.5*Es/N0=0.5*SNR

        transmitted_binary_stream = randsrc(1,NumberOfSymbols, [1 0]);
        [binary_word_stream] = binary_stream_to_binary_word_stream( ...
                                  transmitted_binary_stream, ...
                                  BITS_PER_WORD);

        [symbol_stream]=one_to_one_mapper(binary_word_stream,Binary_Alphabet,Complex_Alphabet);

        received_symbol_stream = awgn(symbol_stream,SNR_dB,'measured');

        [decoded_complex_stream] = ...
                AWGN_maximum_likelyhood_hard_decision_decoder( ...
                    received_symbol_stream, ...
                    Complex_Alphabet, ...
                    Complex_Alphabet);

        [received_binary_word_stream] = ...
            one_to_one_mapper(decoded_complex_stream, ...
                               Complex_Alphabet, ...
                               Binary_Alphabet);

        [received_binary_stream] = ...
            binary_word_stream_to_binary_stream( ...
                received_binary_word_stream, ...
                BITS_PER_WORD);

        ERRORS = ERRORS + ...
                  (NumberOfSymbols - ...
                   sum(transmitted_binary_stream == received_binary_stream.'));

        SYMBOLS = SYMBOLS + NumberOfSymbols;
    end
    SNR=[SNR EbN0];
    BER=[BER (ERRORS / SYMBOLS)];
end
semilogy(SNR,BER);grid;title('Bit error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)');ylabel('BER')

EbN0 = EbN0_min:step:EbN0_max;
matlab_BER = berawgn(EbN0, 'psk', M, 'nondiff');

hold off
figure(2)
semilogy(EbN0,matlab_BER);grid;title('Bit error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)');ylabel('BER')