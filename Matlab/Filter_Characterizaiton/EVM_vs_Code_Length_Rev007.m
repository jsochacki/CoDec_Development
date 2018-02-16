clear all

%%% This uses The test number to calculate the EVM vs the code length for
%%% a user selectible filter

test_number_vector = [25 29];
SYSTEM = 1;

%%% Alphabet Information
complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';
BITS_PER_WORD = 2;

%%% Transmit Information
PN_Length = 2^21;
c = randsrc(1,PN_Length,complex_mapping,123);

symbol_pn_sizes = power(2, [10:1:18]);

EVM_dB_vector{1, length(test_number_vector)} = ...
    zeros(1, length(symbol_pn_sizes));

for test_number = test_number_vector

    %Setup test cases
    test_vector = test_vectors_top_level(test_number);
    if size(test_vector{1},2) > 1
        USAMPR = 2;
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
        Prefix = randsrc(1, 2 * (1 + USAMPR * 120),complex_mapping,3);
        filter_name{test_number} = sprintf(['%s IL @ Fc IIR Filter'], ...
                               test_vector{1}{1});
        
        %Calculate receiver filter before loop
        g = upsample(c'.', USAMPR);
        g = custom_filter(g, sos, fos, k);
        ind = (length(Prefix) * USAMPR);
    else
        USAMPR = 32;
        %Load the FIR Filter
        test_variables = load('filter_coefficients.mat', test_vector{1}{:});
        test_variables.pn_length = test_vector{2};
        stream_pn_length = BITS_PER_WORD * test_variables.pn_length;
        test_variables.EbNo = test_vector{3};
        test_variables.BER = test_vector{4};
        %Access is done dynamically in the following manner
        h = test_variables.(test_vector{1}{1});
        Prefix = randsrc(1, 2 * length(h),complex_mapping,3);
        filter_name{test_number} = sprintf(['%s IL @ Fc FIR Filter'], ...
                               test_vector{1}{1});

        %Calculate receiver filter before loop
        g = upsample(c'.', USAMPR);
        g = conv(g, h);
        g = g(( 1 + ((length(h) - 1) / 2)) ...
                :( end -  ((length(h) - 1) / 2)));
        ind = (length(Prefix) * USAMPR) + ((length(h) - 1) / 2);
        ind2 = (length(Prefix) * USAMPR) + 2*((length(h) - 1) / 2);
    end

    index = 1;
    for symbol_pn_size = symbol_pn_sizes
        NSYMBOLS = PN_Length / symbol_pn_size;

        %%% Sequence Generation
        s = randsrc(1,NSYMBOLS,complex_mapping,233);

        cx = zeros(1, PN_Length); n = 0;
        while (n < length(s))
            indicies = 1 + (n*symbol_pn_size):(n+1)*symbol_pn_size;
            cx(indicies) = (s(n + 1) * c(indicies));
            n = n + 1;
        end

        %Transmit Filtering
        cx = [Prefix cx Prefix];
        cxup = upsample(cx,USAMPR);

        %Filter
        if size(test_vector{1},2) > 1
            sout_iir = custom_filter(cxup, sos, fos, k);
        else
            sout_iir = conv(cxup, h);
        end

        %Normalize
        sout_iir = sout_iir ./ max(abs(sout_iir));
        
        n = 0; r3 = [];
        %Receive Filtering
        if SYSTEM == 1
            %Filter
            if size(test_vector{1},2) > 1
                sout_iir = fliplr(sout_iir);
                sout_iir = custom_filter(sout_iir, sos, fos, k);
                sout_iir = fliplr(sout_iir);
                f3 = sout_iir(1+ind:end-ind);
            else
                sout_iir = conv(sout_iir, fliplr(h));
                f3 = sout_iir(1+ind2:end-ind2);
            end
            f3 = downsample(f3, USAMPR);
            while (n < length(s))
                indicies = (1 + (n * (symbol_pn_size))) ...
                           :((n+1) * (symbol_pn_size));
                r3 = [r3 (f3(indicies) * c(indicies)')];
                n = n + 1;
            end
            r3 = r3 / symbol_pn_size;
            r3 = AGC2(r3, 1, 0);
        else
            f3 = sout_iir(1+ind:end-ind);
            while (n < length(s))
                indicies = (1 + (n * (symbol_pn_size * USAMPR))) ...
                           :((n+1) * (symbol_pn_size * USAMPR));
                r3 = [r3 (f3(indicies) * g(indicies).')];
                n = n + 1;
            end
            r3 = r3 / symbol_pn_size;
            r3 = AGC2(r3, 1, 0);
        end

        [EsNo_dB EVM_dB] = EsNo_and_EVM(s, r3)
        EVM_dB_vector{test_number}(index) = EVM_dB;
        index = index + 1;
    end
end

figure(1)
hold on
grid on
grid minor
legend_data = [];
LW = {1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 2; 2; 2};
LS = {'-'; '-'; '-'; '-'; '-'; '-'; '-'; '-'; '-'; '-'; '-'; '-'; '-'; ...
      '-'; '-'; 'none'; '-.'; '-.'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; ...
      [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; [ 0.3010 0.7450 0.9330]; ...
      [0.6350 0.0780 0.1840]; ...
      'r'; 'b'; 'c'; 'm'};
MS = {'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'none'; ...
      'none'; 'none'; 'none'; 'none'; 'none'; 'o'; 'none'; 'none'};

index = 1;
for temp = test_number_vector
    plot(symbol_pn_sizes, EVM_dB_vector{temp},'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index})
    legend_data{index} = sprintf('%s', filter_name{temp});
    index = index + 1;
end
title('Signal EVM vs Chips Per Symbol');
xlabel('Chips Per Symbol')
ylabel('EVM (dB)')

legend(legend_data)
ax = gca;
ax.YScale = 'linear';
ax.YTick = -50:5:5;
ax.YGrid = 'on';
ax.YMinorGrid = 'on';

ax.XScale = 'log';
ax.XTick = symbol_pn_sizes;
ax.XGrid = 'on';
ax.XMinorGrid = 'off';
ax.XMinorTick = 'off';
axis([min(symbol_pn_sizes) max(symbol_pn_sizes) -55 -10])
