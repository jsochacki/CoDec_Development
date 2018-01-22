clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This Rev of the script incorporates a very long ML PN code and using a 
%%% spread spectrum modem for the BER testing.  It is done using the srrc
%%% filtering approach so that a baseline is established.
%%% This Rev of the script implements the spreading and despreading in the
%%% traditional manner which is different from the way that I implemented
%%% the spreading during mathematical and simulation development.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Prototypes for troubleshooting
fft_db = @(x) 20*log10(fftshift(abs(fft(x, 2^14))));
msp = @(x) (1/length(x)) * sum(x .* x'.');
mspnoringud = @(x,y) (1/(length(x)-(2*y))) * sum(x((1+(y)):1:(end-(y))) .* x((1+(y)):1:(end-(y)))'.');

%Test Specifics
averages = 40;

%RNG Settings
rng('default');
seed_vector = 1:1:averages;
rng(seed_vector(1), 'twister');

%PN Code Settings
lengthPNGI = 53; lengthPNGQ = lengthPNGI;

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

for test_number = 1:1:1
    %Setup test cases
    test_vector = test_vectors_top_level(test_number);

    %Load the IIR Filter
    
    test_variables = load('filter_coefficients.mat', test_vector{1}{:});
    test_variables.pn_length = test_vector{2};
    stream_pn_length = BITS_PER_WORD * test_variables.pn_length;
    test_variables.EbNo = test_vector{3};
    test_variables.BER = test_vector{4};
    %Access is done dynamically in the following manner
    sos = test_variables.(test_vector{1}{1});
    fos = test_variables.(test_vector{1}{2});
    k = test_variables.(test_vector{1}{3});

    AVERAGE_BER = {};
    for seed = 1:1:averages
        EbNo_vec=[]; BER=[];
        rng(seed_vector(seed), 'twister');
        initPNGMatrixI = randsrc(1, lengthPNGI, [0,1]);
        initPNGMatrixQ = randsrc(1, lengthPNGQ, [0,1]);
        for EbN0 = test_variables.EbNo
            EbN0
            ERRORS = 0;
            BITCOUNT = 0;
            NumberOfBits = ((2^18) / stream_pn_length);
            if EbN0 < 3
                ERRORLIMIT = 2000;
            elseif (EbN0 >= 3) & (EbN0 < 6)
                ERRORLIMIT = 1400;
            elseif (EbN0 >= 6) & (EbN0 < 7)
                ERRORLIMIT = 1000;
            elseif (EbN0 >= 7) & (EbN0 < 8)
                ERRORLIMIT = 600;
            else
                ERRORLIMIT = 400;
            end
            pnGI = comm.PNSequence('Polynomial', ...
                                   [53 6 2 1 0], ...
                                   'SamplesPerFrame', ...
                                   test_variables.pn_length, ...
                                   'InitialConditions', ...
                                   initPNGMatrixI);
            pnGQ = comm.PNSequence('Polynomial', ...
                                   [53 6 2 1 0], ...
                                   'SamplesPerFrame', ...
                                   test_variables.pn_length, ...
                                   'InitialConditions', ...
                                   initPNGMatrixQ);
            while ERRORS < ERRORLIMIT
                ERRORS
                (ERRORS / BITCOUNT)
                %Create desired bit stream
                %I and Q mapped to QPSK per DVBS2 spec (I MSB Q LSB)
                s = randsrc(NumberOfBits, 1, [1 0]);

                cI = zeros(NumberOfBits * test_variables.pn_length, 1);
                cQ = zeros(NumberOfBits * test_variables.pn_length, 1);
                transmitted_binary_stream = ...
                    zeros(NumberOfBits * stream_pn_length, 1);
                c = zeros(NumberOfBits * stream_pn_length, 1);

                n = 0;
                while (n < length(s))
                    stream_indicies = ...
                       (1 + (n * stream_pn_length)):...
                       ((n + 1) * stream_pn_length);
                    pnindicies = ...
                       (1 + (n * test_variables.pn_length)):...
                       ((n + 1) * test_variables.pn_length);
                    cIt = (2 * (step(pnGI))) - 1;
                    cQt = (2 * (step(pnGQ))) - 1;
                    c(stream_indicies) = ...
                        [upsample(cIt, 2)] + ...
                         [0; upsample(cQt(1:end-1), 2); cQt(end)];
                    transmitted_binary_stream(stream_indicies) = ...
                        ((2 * s(n + 1)) - 1) * c(stream_indicies);
                    cI(pnindicies) = ((cIt + 1) / 2);
                    cQ(pnindicies) = ((cQt + 1) / 2);
                    n = n + 1;
                end

                %Reset back to bits
                transmitted_binary_stream = ...
                    (transmitted_binary_stream + 1) / 2;

                %append [pre/post]fix to absorb ringup and ringdown
                transmitted_binary_stream = ...
                    [pre_post_fix; transmitted_binary_stream; pre_post_fix];

                %Map the binary stream to a word stream
                binary_word_stream = binary_stream_to_binary_word_stream2( ...
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
                transmit_filtered_symbol_stream = ...
                    conv(h, upsampled_symbol_stream);

                %Normalize the mean squared power to that of the
                %constellation
                transmit_filtered_symbol_stream = ...
                    AGC2(transmit_filtered_symbol_stream, ...
                        desired_sum_squared_power, ...
                        prefix_symbol_length);

                %Since we are spreading we need to add noise at the chip
                %level so I convert EbNo to EcNoo for the AWGN function
                EcN0 = EbN0 - 10*log10(stream_pn_length);
                %Add AWGN to signals   
                received_symbol_stream = ...
                    AWNG_Generator2(transmit_filtered_symbol_stream, ...
                                   EcN0, ...
                                   USAMPR, ...
                                   prefix_symbol_length, ...
                                   BITS_PER_WORD);

                %SRRC filtering routine  
                receive_filtered_symbol_stream = ...
                    conv(fliplr(h), received_symbol_stream);

                %Down sample the signals
                downsampled_receive_filtered_symbol_stream = ...
                    downsample(receive_filtered_symbol_stream, USAMPR);

                %Throw away pre and post fix and therefore ring up and down
                downsampled_receive_filtered_symbol_stream = ...
                    downsampled_receive_filtered_symbol_stream(...
                        (1 + prefix_symbol_length + NSYMBOLS_LONG_FILTER) ...
                            : ...
                        (end - prefix_symbol_length - NSYMBOLS_LONG_FILTER));

                %Normalize the mean squared power to that of the
                %constellation
                downsampled_receive_filtered_symbol_stream = ...
                    AGC(downsampled_receive_filtered_symbol_stream, ...
                        desired_sum_squared_power);

                %Correlate I and Q in the classical sense
                r = zeros(NumberOfBits, 1);
                n = 0;
                while (n < length(s))
                    i_indicies = ...
                        (1 + (n * stream_pn_length))...
                        :2:...
                        ((n + 1) * stream_pn_length);
                    q_indicies = ...
                        (2 + (n * stream_pn_length))...
                        :2:...
                        ((n + 1) * stream_pn_length);
                    symbol_indicies = ...
                       (1 + (n * test_variables.pn_length)):...
                       ((n + 1) * test_variables.pn_length);
                    r(n + 1) = ...
                        (real(downsampled_receive_filtered_symbol_stream(symbol_indicies).') * ...
                        c(i_indicies)) +...
                        (imag(downsampled_receive_filtered_symbol_stream(symbol_indicies).') * ...
                        c(q_indicies));
                    n = n + 1;
                end
                %Correct way to do it mathematically but for safety sake
                %I'll do the one below instead
                %r = r / stream_pn_length;
                r = r / max(abs(r));

                %Since you are doing an xor operation when you are doing
                %spreading in the classical sense and using binary you end
                %up with no inversion of the chipping sequence when your
                %data bit is zero and when your data is a one you end up
                %with an inversion of the chipping sequence
                % e.g.  [0] xor [1 0 1 0] = [1 0 1 0]
                % while [1] xor [1 0 1 0] = [0 1 0 1]
                % so when you are doing the receive correlation you just
                % xor again by the chipping sequence and sum and you end up
                % with the summation of the chipping sequence correlation
                % going to zero when you had a zero data bit and length(PN)
                % when you had a one data bit
                % e.g.  [0] xor [1 0 1 0] = [1 0 1 0] and 
                % [1 0 1 0] xor [1 0 1 0] = [0 0 0 0] and
                % sum([0 0 0 0]) = 0
                % while [1] xor [1 0 1 0] = [0 1 0 1] and 
                % [0 1 0 1] xor [1 0 1 0] = [1 1 1 1] and
                % sum([1 1 1 1]) = 4 = length(PN)
                % INSTEAD
                % When you replace an xor opperation with a multiplication
                % operation by converting a 0 to -1 and 1 to 1 then you end
                % up with a zero bit inverting the chipping sequence and a
                % 1 bit not inverting the chipping sequence as shown below
                % e.g.  [-1] .* [1 -1 1 -1] = [-1 1 -1 1]
                % while [1] .* [1 -1 1 -1] = [1 -1 1 -1]
                % Then when you do the the receive multiplication and sum
                % you end up with the summation of the chipping sequence
                % correlation going to -length(PN) when you had a zero data
                % bit as that was converted to a -1 and was inverting on
                % the initial pn sequence and the correlation going to
                % length(PN) when you had a one data bit as that was
                % converted to a 1 and was non inverting as shown below
                % e.g.  [-1] .* [1 -1 1 -1] = [-1 1 -1 1] and 
                % [-1 1 -1 1] .* [1 -1 1 -1] = [-1 -1 -1 -1] and
                % sum([-1 -1 -1 -1]) = -4 = -length(PN)
                % while [1] .* [1 -1 1 -1] = [1 -1 1 -1] and 
                % [1 -1 1 -1] .* [1 -1 1 -1] = [1 1 1 1] and
                % sum([1 1 1 1]) = 4 = length(PN)
                % So the point of all of that was to say, you either want
                % to invert the chipping sequence on either the transmit or
                % the receive sequence or you want to take the result of
                % the correlation and invert that before thresholding back
                % to bits.  Either is equivalent so do whatever you like
                % or is easier.  In this case doing r = r < 0 is easier so
                % that in the future you don't foreget that you are
                % chipping the tx or rx by -c and have issues that are hard
                % to track down as this is much more apparent upon the
                % inspection of the code
                r = r < 0 ;

                %Hard decision decoders
                decoded_complex_stream = ...
                        AWGN_maximum_likelyhood_hard_decision_decoder( ...
                            downsampled_receive_filtered_symbol_stream, ...
                            Complex_Alphabet, ...
                            Complex_Alphabet);

                %Map from complex to binary word streams
                received_binary_word_stream = ...
                    one_to_one_mapper2(decoded_complex_stream, ...
                                       Complex_Alphabet, ...
                                       Binary_Alphabet);

                %Map from binary word streams to binary streams
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
                           sum(s == ...
                               r));

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

    EbNo_vec = test_variables.EbNo;
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
%     ax.YScale = 'log';
%     ax.XTickMode = 'manual'
%     ax.XMinorTick = 'on'
%     axis([min(EbNo_vec) max(EbNo_vec) 1e-2 1e-1])

    save(sprintf('Results\\BER_Test_Script_Rev007_%d_averages_test_number_%d_Results.mat', ...
         seed, ...
         test_number), ...
         'EbNo_vec', ...
         'BITS_PER_WORD', ...
         'BER', ...
         'seed', ...
         'test_number')
end