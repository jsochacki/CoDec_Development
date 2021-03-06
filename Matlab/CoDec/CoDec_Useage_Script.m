clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This Script shows how to use the CoDec function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Prototypes for troubleshooting
fft_db = @(x) 20*log10(fftshift(abs(fft(x, 2^14))));
msp = @(x) (1/length(x)) * sum(x .* x'.');
mspnoringud = @(x,y) (1/(length(x)-(2*y))) * sum(x((1+(y)):1:(end-(y))) .* x((1+(y)):1:(end-(y)))'.');

%Test Specifics
averages = 20;
EbN0_vec = [0:0.05:0.45];

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
NSYMBOLS_LONG_FILTER = 120;
USAMPR = 2; ROLLOFF = 0.1; ORDER = USAMPR * NSYMBOLS_LONG_FILTER;
SYMBOL_RATE = 1; Fc = SYMBOL_RATE / 2;

h = firrcos(ORDER, Fc, ROLLOFF, USAMPR, 'rolloff', 'sqrt');

pre_post_fix = randsrc(1, length(h) * 2, unique(Binary_Alphabet).').';
prefix_bit_length = length(pre_post_fix);
prefix_symbol_length = length(pre_post_fix) / BITS_PER_WORD;

%Noise setting
desired_sum_squared_power = ...
    (1/length(Complex_Alphabet)) * (Complex_Alphabet * Complex_Alphabet');

%Codec Stuff
CoDec('initialize','test.ini');

for test_number = 1:1:1
    AVERAGE_BER = {};
    for seed = 1:1:averages
        EbNo_vec=[]; BER=[];
        rng(seed_vector(seed), 'twister');
        for EbN0 = EbN0_vec
            EbN0
            ERRORS = 0;
            BITCOUNT = 0;
            NumberOfBits = 16008;
            if EbN0 < 0
                ERRORLIMIT = 2000;
            elseif (EbN0 >= 0) & (EbN0 < 0.3)
                ERRORLIMIT = 1400;
            elseif (EbN0 >= 0.3) & (EbN0 < 0.4)
                ERRORLIMIT = 500;
            elseif (EbN0 >= 0.4) & (EbN0 < 0.5)
                ERRORLIMIT = 10;
            else
                ERRORLIMIT = 1;
            end
            while ERRORS < ERRORLIMIT
                ERRORS
                EbN0
                (ERRORS / BITCOUNT)
                %Create desired bit stream
                s = randsrc(NumberOfBits, 1, [1 0]);

                encoded_s = CoDec('encode', s);
                %Map the data binary stream to a word stream
                data_binary_word_stream = binary_stream_to_binary_word_stream2( ...
                                          encoded_s, ...
                                          BITS_PER_WORD);

                %Map the data word stream to a symbol stream
                data_symbol_stream = ...
                    one_to_one_mapper2(data_binary_word_stream, ...
                                       Binary_Alphabet, ...
                                       Complex_Alphabet);

                %Map the [pre/post]fix binary stream to a word stream
                pre_post_fix_word_stream = binary_stream_to_binary_word_stream2( ...
                                          pre_post_fix, ...
                                          BITS_PER_WORD);

                %Map the [pre/post]fix word stream to a symbol stream
                pre_post_fix_symbol_stream = ...
                    one_to_one_mapper2(pre_post_fix_word_stream, ...
                                       Binary_Alphabet, ...
                                       Complex_Alphabet);


                %append [pre/post]fix to absorb ringup and ringdown
                transmitted_symbol_stream = ...
                    [pre_post_fix_symbol_stream; ...
                     data_symbol_stream; ...
                     pre_post_fix_symbol_stream];

                %Up sample the symbols
                upsampled_symbol_stream = ...
                    upsample(transmitted_symbol_stream, USAMPR);

                %SRRC filtering routine                
                transmit_filtered_symbol_stream = ...
                    conv(h, upsampled_symbol_stream);

                %Normalize the mean squared power to that of the
                %constellation
                transmit_filtered_symbol_stream = ...
                    AGC2(transmit_filtered_symbol_stream, ...
                        desired_sum_squared_power, ...
                        prefix_symbol_length);

                EbcN0 = EbN0 + 10*log10(16008/64800);
                %Add AWGN to signals   
                received_symbol_stream = ...
                    AWNG_Generator2(transmit_filtered_symbol_stream, ...
                                   EbcN0, ...
                                   USAMPR, ...
                                   prefix_symbol_length, ...
                                   BITS_PER_WORD);

               %SRRC filtering routine  
                filtered_received_symbol_stream = ...
                    conv(fliplr(h), received_symbol_stream);

                %Throw away pre and post fix and therefore ring up and down
                filtered_received_symbol_stream = ...
                    filtered_received_symbol_stream(...
                        (1 + (prefix_symbol_length * USAMPR) + ...
                             ((NSYMBOLS_LONG_FILTER) * USAMPR)) ...
                            : ...
                        (end - ((prefix_symbol_length * USAMPR) + ...
                               ((NSYMBOLS_LONG_FILTER) * USAMPR))));
                           
                %Down sample the signals
                downsampled_filtered_received_symbol_stream = ...
                    downsample(filtered_received_symbol_stream, USAMPR);
                
                %Normalize the mean squared power to that of the
                %constellation
                downsampled_filtered_received_symbol_stream = ...
                    AGC(downsampled_filtered_received_symbol_stream, ...
                        desired_sum_squared_power);

                [received_binary_stream, decoder_iterations] = ...
                    CoDec('decode', downsampled_filtered_received_symbol_stream);               

                ERRORS = ERRORS + ...
                          (NumberOfBits - ...
                           sum(s == ...
                               received_binary_stream));

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

    EbNo_vec = EbN0_vec;
    matlab_BER = berawgn(EbNo_vec, 'psk', power(2, BITS_PER_WORD), 'nondiff');

    figure(1)
    hold on
    grid on
    grid minor
    legend_data = [];
    LW = {1; 2; 2; 2};
    LS = {'none'; '-'; '-.'; '-.'};
    LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]};
    MS = {'o'; 'none'; 'none'; 'none'};
    plot(EbNo_vec,BER,'LineWidth',LW{1},'LineStyle',LS{1},'Marker',MS{1},'Color',LC{1})
    legend_data{1} = 'Simulation';
    plot(EbNo_vec,matlab_BER,'LineWidth',LW{2},'LineStyle',LS{2},'Marker',MS{2},'Color',LC{2})
    legend_data{2} = 'Analytic';
    if exist('seed', 'var')
        title(sprintf(['QPSK Bit Error Rate Over Stationary AWGN Channel\n' ...
                      '%d Test Averages'], seed));
    else
        title('QPSK Bit Error Rate Over Stationary AWGN Channel');
    end
    xlabel('Eb/No (dB)')
    ylabel('BER')

    legend(legend_data)
    ax = gca;
    ax.YScale = 'log';
    ax.XTickMode = 'manual'
    ax.XMinorTick = 'on'
    axis([min(EbNo_vec) max(EbNo_vec) 1e-4 1e-0])

end