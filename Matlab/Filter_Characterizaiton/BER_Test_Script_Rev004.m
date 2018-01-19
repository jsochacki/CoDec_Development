clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This Rev of the script does BER calculations for the IIR filter using
%%% the signal reverse and filter method for matched filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Prototypes for troubleshooting
fft_db = @(x) 20*log10(fftshift(abs(fft(x, 2^14))));

%Test Specifics
averages = 20;

%RNG Settings
rng('default');
seed_vector = 1:1:averages;
rng(seed_vector(1), 'twister');

%MODCOD Settings
MODCOD = 1;

[Complex_Alphabet, ...
 Binary_Alphabet, ...
 Decimal_Alphabet, ...
 BITS_PER_WORD] ...
     = dvbs2_Constellations(MODCOD);

%SRRC Filter for Comparison
NSYMBOLS_LONG_FILTER=120;
USAMPR=2; ROLLOFF=0.1; ORDER=USAMPR*NSYMBOLS_LONG_FILTER;
SYMBOL_RATE=1; Fc=SYMBOL_RATE/2;

h=(firrcos(ORDER,Fc,ROLLOFF,USAMPR,'rolloff','sqrt'));

pre_post_fix = randsrc(1, length(h) * 2, unique(Binary_Alphabet).');
prefix_bit_length = length(pre_post_fix);
prefix_symbol_length = length(pre_post_fix) / BITS_PER_WORD;

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
    for seed = 1:1:averages
        EbNo_vec=[]; BER=[];
        rng(seed_vector(seed), 'twister');
        for EbN0 = EbN0_min:step:EbN0_max
            EbN0
            ERRORS = 0; BITCOUNT = 0;
            if EbN0 < 3
                ERRORLIMIT = 1000;
                NumberOfBits = 2^14;
            elseif (EbN0 >= 3) & (EbN0 < 6)
                ERRORLIMIT = 700;
                NumberOfBits = 2^15;
            elseif (EbN0 >= 6) & (EbN0 < 7)
                ERRORLIMIT = 500;
                NumberOfBits = 2^16;
            elseif (EbN0 >= 7) & (EbN0 < 8)
                ERRORLIMIT = 300;
                NumberOfBits = 2^17;
            else
                ERRORLIMIT = 200;
                NumberOfBits = 2^18;
            end
            while ERRORS < ERRORLIMIT
                ERRORS

                %Create desired bit stream
                transmitted_binary_stream = ...
                    randsrc(1,NumberOfBits, [1 0]);

                %append [pre/post]fix to absorb ringup and ringdown
                transmitted_binary_stream = ...
                    [pre_post_fix transmitted_binary_stream pre_post_fix];

                %Map the binary stream to a word stream
                [binary_word_stream] = binary_stream_to_binary_word_stream( ...
                                          transmitted_binary_stream, ...
                                          BITS_PER_WORD);

                %Map the word stream to a symbol stream
                [symbol_stream] = ...
                    one_to_one_mapper2(binary_word_stream, ...
                                       Binary_Alphabet, ...
                                       Complex_Alphabet);

                %Up sample the symbols
                upsampled_symbol_stream = upsample(symbol_stream, USAMPR);

%                 %SRRC filtering routine                
%                 transmit_filtered_symbol_stream = ...
%                     conv(h, upsampled_symbol_stream);

                %IIR filtering routine                
                transmit_filtered_symbol_stream = ...
                    custom_filter(upsampled_symbol_stream, ...
                                  sos, ...
                                  fos, ...
                                  k);

                %Normalize the mean squared power to that of the
                %constellation
                transmit_filtered_symbol_stream = ...
                    AGC(transmit_filtered_symbol_stream, ...
                        desired_sum_squared_power);

                %Add AWGN to signal
                received_symbol_stream = ...
                    AWNG_Generator2(transmit_filtered_symbol_stream, ...
                                   EbN0, ...
                                   USAMPR, ...
                                   prefix_symbol_length, ...
                                   BITS_PER_WORD);

%                 %SRRC filtering routine  
%                 receive_filtered_symbol_stream = ...
%                     conv(fliplr(h), received_symbol_stream);

%DANGER HERE, YOU DO NOTHING TO MAKE SURE IT IS A COLUMN BEFORE DOING THIS
%AND FLIPUD WHERE IF IT IS A ROW IT WILL FAIL AND GIVE HORRIBLE RESULTS AS
%IT WONT FLIP ANYTHING
                %IIR filtering routine
                receive_filtered_symbol_stream = ...
                    custom_filter(flipud(received_symbol_stream), ...
                                  sos, ...
                                  fos, ...
                                  k);

                %Flip back due to way I'm doing IIR filtering
                receive_filtered_symbol_stream = ...
                    flipud(receive_filtered_symbol_stream);

                %Down sample the signal
                downsampled_receive_filtered_symbol_stream = ...
                    downsample(receive_filtered_symbol_stream, USAMPR);

                %Throw away pre and post fix and therefore ring up and down
                downsampled_receive_filtered_symbol_stream = ...
                    downsampled_receive_filtered_symbol_stream(...
                    (1 + prefix_symbol_length):(end - prefix_symbol_length));

                %Normalize the mean squared power to that of the
                %constellation
                downsampled_receive_filtered_symbol_stream = ...
                    AGC(downsampled_receive_filtered_symbol_stream, ...
                        desired_sum_squared_power);

                %Hard decision decoder
                decoded_complex_stream = ...
                        AWGN_maximum_likelyhood_hard_decision_decoder( ...
                            downsampled_receive_filtered_symbol_stream, ...
                            Complex_Alphabet, ...
                            Complex_Alphabet);

                %Map from complex to binary word stream
                received_binary_word_stream = ...
                    one_to_one_mapper2(decoded_complex_stream, ...
                                       Complex_Alphabet, ...
                                       Binary_Alphabet);

                %Map from binary word stream to binary stream
                received_binary_stream = ...
                    binary_word_stream_to_binary_stream( ...
                        received_binary_word_stream, ...
                        BITS_PER_WORD);

                %Throw away pre fix and post fix bits on original signal
                %for BER calculations
                transmitted_binary_stream = ...
                    transmitted_binary_stream(...
                    (1 + prefix_bit_length): ...
                    (end - prefix_bit_length));

                ERRORS = ERRORS + ...
                          (NumberOfBits - ...
                           sum(transmitted_binary_stream == ...
                               received_binary_stream.'));

                BITCOUNT = BITCOUNT + NumberOfBits;
            end
            EbNo_vec=[EbNo_vec EbN0];
            BER=[BER (ERRORS / BITCOUNT)];
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
    title('QPSK Bit Error Rate Over Stationary AWGN Channel');
    xlabel('Eb/No (dB)')
    ylabel('BER')

    legend(legend_data)
    ax = gca;
    ax.YScale = 'log';
    ax.XTickMode = 'manual'
    ax.XMinorTick = 'on'
    axis([min(EbNo_vec) max(EbNo_vec) 1e-6 1e-1])

    save(sprintf('Results\\BER_Test_Script_Rev004_%d_averages_test_number_%d_Results.mat', ...
         seed, ...
         test_number), ...
         'EbNo_vec', ...
         'BITS_PER_WORD', ...
         'BER', ...
         'seed', ...
         'test_number')
end