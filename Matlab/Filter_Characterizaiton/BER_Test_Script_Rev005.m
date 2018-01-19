clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This Rev of the script does a direct comparison of the BER obtained
%%% from the two different filters (SRRC and IIR).  It takes the
%%% difference in the BER between the two methods obtained from identical
%%% bit streams and identical time point by point noise (i.e. the exact
%%% same enoise is added to each stream) and calls that BER DEGRADATION.
%%% A positive BER DEGRADATION is actual degradation while negative is
%%% enhancement.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Prototypes for troubleshooting
fft_db = @(x) 20*log10(fftshift(abs(fft(x, 2^14))));
msp = @(x) (1/length(x)) * sum(x .* x'.');
mspnoringud = @(x,y) (1/(length(x)-(2*y))) * sum(x((1+(y)):1:(end-(y))) .* x((1+(y)):1:(end-(y)))'.');

%Test Specifics
averages = 2;

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

    AVERAGE_BER_DEGRADATION = {};
    for seed = 1:1:averages
        EbNo_vec=[]; BER_DEGRADATION=[];
        rng(seed_vector(seed), 'twister');
        for EbN0 = EbN0_min:step:EbN0_max
            EbN0
            SRRC_ERRORS = 0;
            IIR_ERRORS = 0;
            BITCOUNT = 0;
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
            while ((SRRC_ERRORS + IIR_ERRORS) / 2) < ERRORLIMIT
                SRRC_ERRORS
                IIR_ERRORS

                %Create desired bit stream
                transmitted_binary_stream = ...
                    randsrc(1,NumberOfBits, [1 0]);

                %append [pre/post]fix to absorb ringup and ringdown
                transmitted_binary_stream = ...
                    [pre_post_fix transmitted_binary_stream pre_post_fix];

                %Map the binary stream to a word stream
                binary_word_stream = binary_stream_to_binary_word_stream( ...
                                          transmitted_binary_stream, ...
                                          BITS_PER_WORD);

                %Map the word stream to a symbol stream
                symbol_stream = ...
                    one_to_one_mapper2(binary_word_stream, ...
                                       Binary_Alphabet, ...
                                       Complex_Alphabet);

                %Up sample the symbols
                upsampled_symbol_stream = upsample(symbol_stream, USAMPR);

                %SRRC filtering routine                
                srrc_transmit_filtered_symbol_stream = ...
                    conv(h, upsampled_symbol_stream);

                %IIR filtering routine                
                transmit_filtered_symbol_stream = ...
                    custom_filter(upsampled_symbol_stream, ...
                                  sos, ...
                                  fos, ...
                                  k);

                %Normalize the mean squared power to that of the
                %constellation
                srrc_transmit_filtered_symbol_stream = ...
                    AGC2(srrc_transmit_filtered_symbol_stream, ...
                        desired_sum_squared_power, ...
                        prefix_symbol_length);
                transmit_filtered_symbol_stream = ...
                    AGC2(transmit_filtered_symbol_stream, ...
                        desired_sum_squared_power, ...
                        prefix_symbol_length);

                %Add AWGN to signals
                %%% Notes on equivalency and valitidy
                %We somewhat incorrectly assume that the power of the srrc
                %and the iir signal are identical such that the noise added
                %gives an identical SNR.  It is as close to that as we can
                %get since we AGC the signals before going into this
                %function and then we remove the same [pre/post]fix but
                %there is bound to be a small difference due to the fact
                %that the AGC is done on the entire signal with ring up and
                %ring down and the filter characteristics are different.
                %How much?  Testing found less than 0.01dB.
                %Just to be on the safe side I modified some functions to
                %remove this small difference.
                %So what I did is i modified the AGC to be on just the
                %signal portion without the ringup/ringdown/[pre/post]fix
                %portion of the signal and now their msp calculated in the
                %AWGN function is identical and therefore their SNR will be
                %identical.
                %NOTE that the [pre/post]fix is 4 times aslong as the ring
                %up and down from one convolutional filtering operation and
                %2 times as long as the ringup/ringdown from a full matched
                %filtering operation so that is why it is used over the
                %length of the filter in symbols, this way the same amount
                %of signal can be removed from both signals.
                %Also, the difference in the signals due to filtering is
                %now gone due to the AGC being done on just the signal with
                %no ring and landing them at the exact same power level
                %There was one small problem that arose which is the vector
                %length of the noise is different due to the different ring
                %up and ring down lengths of the filters which have made
                %the overall signals slightly different length so I have
                %skewed the odds against me and added zero noise to the
                %srrc signal where it had additional length over that of
                %the iir signal
                Addative_White_Gaussian_Noise = ...
                    AWNG_Noise_Generator(transmit_filtered_symbol_stream, ...
                                         EbN0, ...
                                         USAMPR, ...
                                         prefix_symbol_length, ...
                                         BITS_PER_WORD);
                srrc_received_symbol_stream = ...
                    srrc_transmit_filtered_symbol_stream + ...
                    [zeros(ORDER/2, 1); ...
                     Addative_White_Gaussian_Noise; ...
                     zeros(ORDER/2, 1)];
                received_symbol_stream = ...
                    transmit_filtered_symbol_stream + ...
                    Addative_White_Gaussian_Noise;

%                 %msp checks
%                 msp(srrc_transmit_filtered_symbol_stream);
%                 msp(transmit_filtered_symbol_stream);
%                 mspnoringud(srrc_transmit_filtered_symbol_stream,prefix_symbol_length);
%                 mspnoringud(transmit_filtered_symbol_stream,prefix_symbol_length);
                
%                 srrc_received_symbol_stream = ...
%                     AWNG_Generator2(srrc_transmit_filtered_symbol_stream, ...
%                                    EbN0, ...
%                                    USAMPR, ...
%                                    prefix_symbol_length, ...
%                                    BITS_PER_WORD);
%                 received_symbol_stream = ...
%                     AWNG_Generator2(transmit_filtered_symbol_stream, ...
%                                    EbN0, ...
%                                    USAMPR, ...
%                                    prefix_symbol_length, ...
%                                    BITS_PER_WORD);

                %SRRC filtering routine  
                srrc_receive_filtered_symbol_stream = ...
                    conv(fliplr(h), srrc_received_symbol_stream);

                %IIR filtering routine
                receive_filtered_symbol_stream = ...
                    custom_filter(flipud(received_symbol_stream), ...
                                  sos, ...
                                  fos, ...
                                  k);

                %Flip back due to way I'm doing IIR filtering
                receive_filtered_symbol_stream = ...
                    flipud(receive_filtered_symbol_stream);

                %Down sample the signals
                srrc_downsampled_receive_filtered_symbol_stream = ...
                    downsample(srrc_receive_filtered_symbol_stream, USAMPR);
                downsampled_receive_filtered_symbol_stream = ...
                    downsample(receive_filtered_symbol_stream, USAMPR);

                %Throw away pre and post fix and therefore ring up and down
                srrc_downsampled_receive_filtered_symbol_stream = ...
                    srrc_downsampled_receive_filtered_symbol_stream(...
                        (1 + prefix_symbol_length + NSYMBOLS_LONG_FILTER) ...
                            : ...
                        (end - prefix_symbol_length - NSYMBOLS_LONG_FILTER));
                downsampled_receive_filtered_symbol_stream = ...
                    downsampled_receive_filtered_symbol_stream(...
                        (1 + prefix_symbol_length):(end - prefix_symbol_length));

                %Normalize the mean squared power to that of the
                %constellation
                srrc_downsampled_receive_filtered_symbol_stream = ...
                    AGC(srrc_downsampled_receive_filtered_symbol_stream, ...
                        desired_sum_squared_power);
                downsampled_receive_filtered_symbol_stream = ...
                    AGC(downsampled_receive_filtered_symbol_stream, ...
                        desired_sum_squared_power);

                %Hard decision decoders
                srrc_decoded_complex_stream = ...
                        AWGN_maximum_likelyhood_hard_decision_decoder( ...
                            srrc_downsampled_receive_filtered_symbol_stream, ...
                            Complex_Alphabet, ...
                            Complex_Alphabet);
                decoded_complex_stream = ...
                        AWGN_maximum_likelyhood_hard_decision_decoder( ...
                            downsampled_receive_filtered_symbol_stream, ...
                            Complex_Alphabet, ...
                            Complex_Alphabet);

                %Map from complex to binary word streams
                srrc_received_binary_word_stream = ...
                    one_to_one_mapper2(srrc_decoded_complex_stream, ...
                                       Complex_Alphabet, ...
                                       Binary_Alphabet);
                received_binary_word_stream = ...
                    one_to_one_mapper2(decoded_complex_stream, ...
                                       Complex_Alphabet, ...
                                       Binary_Alphabet);

                %Map from binary word streams to binary streams
                srrc_received_binary_stream = ...
                    binary_word_stream_to_binary_stream( ...
                        srrc_received_binary_word_stream, ...
                        BITS_PER_WORD);
                received_binary_stream = ...
                    binary_word_stream_to_binary_stream( ...
                        received_binary_word_stream, ...
                        BITS_PER_WORD);

                %Throw away pre fix and post fix bits on original signal
                %for BER calculations
                %SRRC and IIR are identical up to first tx filter so you
                %only need to do this once and use this for both
                transmitted_binary_stream = ...
                    transmitted_binary_stream(...
                    (1 + prefix_bit_length): ...
                    (end - prefix_bit_length));

                SRRC_ERRORS = SRRC_ERRORS + ...
                          (NumberOfBits - ...
                           sum(transmitted_binary_stream == ...
                               srrc_received_binary_stream.'));

                IIR_ERRORS = IIR_ERRORS + ...
                          (NumberOfBits - ...
                           sum(transmitted_binary_stream == ...
                               received_binary_stream.'));

                BITCOUNT = BITCOUNT + NumberOfBits;
            end
            EbNo_vec=[EbNo_vec EbN0];
            BER_DEGRADATION=[BER_DEGRADATION ...
                ((IIR_ERRORS / BITCOUNT) - (SRRC_ERRORS / BITCOUNT))];
        end

    AVERAGE_BER_DEGRADATION{seed} = BER_DEGRADATION;
    end

    BER_DEGRADATION = 0;
    for seed = 1:1:size(AVERAGE_BER_DEGRADATION, 2)
        BER_DEGRADATION = BER_DEGRADATION + AVERAGE_BER_DEGRADATION{seed};
    end
    BER_DEGRADATION = BER_DEGRADATION / seed;

    figure(1)
    hold on
    grid on
    grid minor
    legend_data = [];
    LW = {1; 2; 2; 2};
    LS = {'none'; '-.'; '-'; '-'};
    LC = {'b'; 'r'; 'b'; 'b'};
    MS = {'o'; 'none'; 'none'; 'none'};
    plot(EbNo_vec,BER_DEGRADATION,'LineWidth',LW{1},'LineStyle',LS{1},'Marker',MS{1},'Color',LC{1})
    legend_data{1} = 'Simulation';
    plot(EbNo_vec,ones(1, length(BER_DEGRADATION)) * mean(BER_DEGRADATION),'LineWidth',LW{2},'LineStyle',LS{2},'Marker',MS{2},'Color',LC{2})
    legend_data{2} = 'Mean Value';
    plot(EbNo_vec,ones(1, length(BER_DEGRADATION)) * (mean(BER_DEGRADATION) + std(BER_DEGRADATION)),'LineWidth',LW{3},'LineStyle',LS{3},'Marker',MS{3},'Color',LC{3})
    legend_data{3} = 'Standard Deviation Bounds';
    plot(EbNo_vec,ones(1, length(BER_DEGRADATION)) * (mean(BER_DEGRADATION) - std(BER_DEGRADATION)),'LineWidth',LW{4},'LineStyle',LS{4},'Marker',MS{4},'Color',LC{4})
    legend_data{4} = 'Standard Deviation Bounds';
    if exist('seed', 'var')
        title(sprintf(['QPSK Bit Error Rate Over Stationary AWGN Channel\n' ...
                      '%d Test Averages'], seed));
    else
        title('QPSK Bit Error Rate Over Stationary AWGN Channel');
    end
    xlabel('Eb/No (dB)')
    ylabel('BER DEGRADATION')

    legend(legend_data)
    ax = gca;
    ax.YScale = 'log';
    ax.XTickMode = 'manual'
    ax.XMinorTick = 'on'
    axis([min(EbNo_vec) max(EbNo_vec) 1e-6 1e-1])

    save(sprintf('Results\\BER_Test_Script_Rev005_%d_averages_test_number_%d_Results.mat', ...
         seed, ...
         test_number), ...
         'EbNo_vec', ...
         'BITS_PER_WORD', ...
         'BER_DEGRADATION', ...
         'seed', ...
         'test_number')
end