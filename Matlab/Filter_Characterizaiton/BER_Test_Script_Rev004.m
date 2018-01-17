clear all

%Prototypes for troubleshooting
fft_db = @(x) 20*log10(fftshift(abs(fft(x, 2^14))));

%RNG Settings
rng('default');
seed_vector = 1:1:20;
rng(seed_vector(1), 'twister');

%MODCOD Settings
MODCOD = 1;

[Complex_Alphabet ...
 Binary_Alphabet ...
 Decimal_Alphabet ...
 BITS_PER_WORD] ...
     = dvbs2_Constellations(MODCOD);

%SRRC Filter for Comparison
NSYMBOLS_LONG_FILTER=120;
USAMPR=2; ROLLOFF=0.1; ORDER=USAMPR*NSYMBOLS_LONG_FILTER;
SYMBOL_RATE=1; Fc=SYMBOL_RATE/2;

h=(firrcos(ORDER,Fc,ROLLOFF,USAMPR,'rolloff','sqrt'));

prefix = randsrc(1, length(h) * 2, unique(Binary_Alphabet).');

%Noise setting
desired_sum_squared_power = ...
    (1/length(Complex_Alphabet)) * (Complex_Alphabet * Complex_Alphabet');
EbN0_min=0; EbN0_max=10; step=0.1;

for test_number = 1:1:1
    %Setup test cases
    test_vector = test_vectors_initial_filter_test_only(test_number);

    %Load the IIR Filter
    
    test_variables = load('filter_coefficients.mat',test_vector{:});
    %Access is done dynamically in the following manner
    sos = test_variables.(test_vector{1});
    fos = test_variables.(test_vector{2});
    k = test_variables.(test_vector{3});

    AVERAGE_BER = {};
    for seed = 1:1:20
        EbNo_vec=[]; BER=[];
        rng(seed_vector(seed), 'twister');
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
                SNR_dB = EbN0 + 10*log10(BITS_PER_WORD) + 10*log10(1/USAMPR);

                transmitted_binary_stream = ...
                    randsrc(1,NumberOfSymbols, [1 0]);

                transmitted_binary_stream = ...
                    [prefix transmitted_binary_stream prefix];

                [binary_word_stream] = binary_stream_to_binary_word_stream( ...
                                          transmitted_binary_stream, ...
                                          BITS_PER_WORD);

                [symbol_stream] = ...
                    one_to_one_mapper2(binary_word_stream, ...
                                       Binary_Alphabet, ...
                                       Complex_Alphabet);

                upsampled_symbol_stream = upsample(symbol_stream, USAMPR);

%                 transmit_filtered_symbol_stream = ...
%                     conv(h, upsampled_symbol_stream);

                transmit_filtered_symbol_stream = ...
                    custom_filter(upsampled_symbol_stream, ...
                                  sos, ...
                                  fos, ...
                                  k);

                transmit_filtered_symbol_stream = ...
                    AGC(transmit_filtered_symbol_stream, ...
                        desired_sum_squared_power);

%                 received_symbol_stream = ...
%                     AWNG_Generator(transmit_filtered_symbol_stream, ...
%                                    EbN0, ...
%                                    USAMPR, ...
%                                    h, ...
%                                    BITS_PER_WORD);

                received_symbol_stream = ...
                    AWNG_Generator(transmit_filtered_symbol_stream, ...
                                   EbN0, ...
                                   USAMPR, ...
                                   ((size(sos, 1) * 2) + 1), ...
                                   BITS_PER_WORD);

%                 receive_filtered_symbol_stream = ...
%                     conv(fliplr(h), received_symbol_stream);

                receive_filtered_symbol_stream = ...
                    custom_filter(flipud(received_symbol_stream), ...
                                  sos, ...
                                  fos, ...
                                  k);

                receive_filtered_symbol_stream = ...
                    flipud(receive_filtered_symbol_stream);


                downsampled_receive_filtered_symbol_stream = ...
                    downsample(receive_filtered_symbol_stream, USAMPR);

%                 downsampled_receive_filtered_symbol_stream = ...
%                     downsampled_receive_filtered_symbol_stream(...
%                     (1 + NSYMBOLS_LONG_FILTER):(end - NSYMBOLS_LONG_FILTER));

                downsampled_receive_filtered_symbol_stream = ...
                    downsampled_receive_filtered_symbol_stream(...
                    (1 + length(prefix)):(end - length(prefix)));

                downsampled_receive_filtered_symbol_stream = ...
                    AGC(downsampled_receive_filtered_symbol_stream, ...
                        desired_sum_squared_power);

                [decoded_complex_stream] = ...
                        AWGN_maximum_likelyhood_hard_decision_decoder( ...
                            downsampled_receive_filtered_symbol_stream, ...
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

                transmitted_binary_stream = ...
                    transmitted_binary_stream(...
                    (1 + (length(prefix) * BITS_PER_WORD)): ...
                    (end - (length(prefix) * BITS_PER_WORD)));

                ERRORS = ERRORS + ...
                          (NumberOfSymbols - ...
                           sum(transmitted_binary_stream == received_binary_stream.'));

                SYMBOLS = SYMBOLS + NumberOfSymbols;
            end
            EbNo_vec=[EbNo_vec EbN0];
            BER=[BER (ERRORS / SYMBOLS)];
        end

    AVERAGE_BER{seed} = BER;
    end

    BER = 0;
    for seed = 1:1:size(AVERAGE_BER, 2)
        BER = BER + AVERAGE_BER{seed};
    end
    BER = BER / seed;

    matlab_BER = berawgn(EbNo_vec, 'psk', power(2, BITS_PER_WORD), 'nondiff');

    figure(1)
    hold on
    grid on
    grid minor
    legend_data = [];
    LS = {'none';'-';'-.';':';':';':';':';':';':'};
    MS = {'o';'none';'-.';':';':';':';':';':';':'};
    plot(EbNo_vec,BER,'LineWidth',1,'LineStyle',LS{1},'Marker','o')
    legend_data{1} = 'Simulation';
    plot(EbNo_vec,matlab_BER,'LineWidth',2,'LineStyle',LS{2})
    legend_data{2} = 'Analytic';
    title('Bit error rate for QPSK over Stationary AWGN Channel');
    xlabel('Eb/No (dB)')
    ylabel('BER')

    legend(legend_data)
    ax = gca;
    ax.YScale = 'log';
    ax.XTickMode = 'manual'
    ax.XMinorTick = 'on'
    axis([min(EbNo_vec) max(EbNo_vec) 1e-6 1e-1])

    save(sprintf('Results\\BER_Test_Script_Rev004_test_number_%d_Results.mat', ...
         test_number), ...
         'EbNo_vec', ...
         'BITS_PER_WORD', ...
         'BER', ...
         'test_number')
end