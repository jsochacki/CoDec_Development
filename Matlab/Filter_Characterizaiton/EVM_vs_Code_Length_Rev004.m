clear all

%%% This uses The IIR filter and calculates the EVM vs the code length for
%%% a user selectible filter

USAMPR = 2;

%SRRC Filter for Comparison
NSYMBOLS_LONG_FILTER = 120; ORDER = USAMPR * NSYMBOLS_LONG_FILTER;
ROLLOFF = 0.1; SYMBOL_RATE = 1; Fc = SYMBOL_RATE / 2;
h = firrcos(ORDER, Fc, ROLLOFF, USAMPR, 'rolloff', 'sqrt');

%IIR Filter Parameter Vectors
fc = 0.5 / USAMPR;
insertion_loss_at_fc = [3 6 9 12 15 18];
transition_region_width = 0.0125;
ripple = 0.001;
rejection = 90;

%%% Alphabet Information
complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';
Prefix = randsrc(1, 2 * length(h),complex_mapping,3);

%%% Transmit Information
PN_Length = 2^21;
c = randsrc(1,PN_Length,complex_mapping,123);

symbol_pn_sizes = power(2, [9:1:18]);

EVM_dB_vector{1, length(insertion_loss_at_fc)} = ...
    zeros(1, length(symbol_pn_sizes));

for il = 1:1:length(insertion_loss_at_fc)
    [sos fos k N] = Chebyshev_IIR_Filter_Designer(fc, ...
                                  insertion_loss_at_fc(il), ...
                                  transition_region_width, ...
                                  ripple, ...
                                  rejection);

    filter_name{il} = sprintf(['%ddB IL @ Fc Filter with ' ...
                           '%1.4f transition region width, ' ...
                           '%1.3fdB ripple, and ' ...
                           '%ddB rejection. ' ...
                           'Order %d '], ...
                           insertion_loss_at_fc(il), ...
                           transition_region_width, ...
                           ripple, ...
                           rejection, ...
                           N);

    %Calculate receiver filter before loop
    g = upsample(c'.', USAMPR);
    g = custom_filter(g, sos, fos, k);
    ind = (length(Prefix) * USAMPR);

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
        sout_iir = custom_filter(cxup, sos, fos, k);

        %Normalize
        sout_iir = sout_iir ./ max(abs(sout_iir));

        %Receive Filtering

        f3 = sout_iir(1+ind:end-ind);
        n = 0; r3 = [];
        while (n < length(s))
            indicies = (1 + (n * (symbol_pn_size * USAMPR))) ...
                       :((n+1) * (symbol_pn_size * USAMPR));
            r3 = [r3 (f3(indicies) * g(indicies).')];
            n = n + 1;
        end
        r3 = r3 / symbol_pn_size;
        r3 = AGC2(r3, 1, 0);

        [EsNo_dB EVM_dB] = EsNo_and_EVM(s, r3)
        EVM_dB_vector{il}(index) = EVM_dB;
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

for index = 1:1:size(EVM_dB_vector, 2)
    plot(symbol_pn_sizes, EVM_dB_vector{index},'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index})
    legend_data{index} = sprintf('%s', filter_name{index});
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
axis([min(symbol_pn_sizes) max(symbol_pn_sizes) -45 -10])
