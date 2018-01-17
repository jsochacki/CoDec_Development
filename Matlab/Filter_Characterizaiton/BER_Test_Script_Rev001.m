
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
AVERAGE_BER = {};
for n = 1:1:2
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
            ERRORLIMIT = 300;
            NumberOfSymbols = 2^17;
        else
            ERRORLIMIT = 200;
            NumberOfSymbols = 2^18;
        end
        while ERRORS < ERRORLIMIT
            ERRORS
            SNR_dB=EbN0 + 3; %for QPSK Eb/N0=0.5*Es/N0=0.5*SNR

            transmitted_binary_stream = randsrc(1,NumberOfSymbols, [1 0]);
            [binary_word_stream] = binary_stream_to_binary_word_stream( ...
                                      transmitted_binary_stream, ...
                                      BITS_PER_WORD);

            [symbol_stream]=one_to_one_mapper2(binary_word_stream,Binary_Alphabet,Complex_Alphabet);

            received_symbol_stream = awgn(symbol_stream,SNR_dB,'measured');

            [decoded_complex_stream] = ...
                    AWGN_maximum_likelyhood_hard_decision_decoder( ...
                        received_symbol_stream, ...
                        Complex_Alphabet, ...
                        Complex_Alphabet);

            [received_binary_word_stream] = ...
                one_to_one_mapper2(decoded_complex_stream, ...
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

AVERAGE_BER{n} = BER;
end

BER = 0;
for n = 1:1:size(AVERAGE_BER, 2)
    BER = BER + AVERAGE_BER{n};
end
BER = BER / n;

EbN0 = EbN0_min:step:EbN0_max;
matlab_BER = berawgn(EbN0, 'psk', M, 'nondiff');

figure(1)
hold on
grid on
grid minor
legend_data = [];
LS = {'none';'-';'-.';':';':';':';':';':';':'};
MS = {'o';'none';'-.';':';':';':';':';':';':'};
plot(EbN0,BER,'LineWidth',1,'LineStyle',LS{1},'Marker','o')
legend_data{1} = 'Simulation';
plot(EbN0,matlab_BER,'LineWidth',2,'LineStyle',LS{2})
legend_data{2} = 'Analytic';
title('Bit error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)')
ylabel('BER')

legend(legend_data)
ax = gca;
ax.YScale = 'log';
ax.XTickMode = 'manual'
ax.XMinorTick = 'on'
% set(ax,'XTick',[8:1:32])
% set(ax,'YTick',[-1:0.1:1])
axis([min(EbN0) max(EbN0) 1e-6 1e-1])