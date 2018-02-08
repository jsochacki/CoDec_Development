clear all

%%% This is a script to generate the impulse response for Randy in the
%%% format that he wants them in

%Prototypes
frequency_response = ...
    @(signal, FFTSIZE) 20*log10(fftshift(abs(fft(signal, FFTSIZE))));
normalized_frequency_response = ...
    @(signal, FFTSIZE) frequency_response(signal, FFTSIZE) - ...
        max(frequency_response(signal, FFTSIZE));

USAMPR = 2; Result_Usampr = 32;

%SRRC Filter for Comparison
NSYMBOLS_LONG_FILTER = 120; ORDER = USAMPR * NSYMBOLS_LONG_FILTER;
ROLLOFF = 0.1; SYMBOL_RATE = 1; Fc = SYMBOL_RATE / 2;
h = firrcos(ORDER, Fc, ROLLOFF, USAMPR, 'rolloff', 'sqrt');

number_of_samples = 2^17;
breakpoints = power(2,1:1:12);

%%% Sequence Generation
s = [1 zeros(1, number_of_samples - 1)];

%IIR Filter Parameter Vectors
fc = 0.5 / USAMPR;
insertion_loss_at_fc = [3 6 9 12 15 18];
transition_region_width = [0.0125 0.0125 0.0125 0.0125 0.0125 0.0125];
ripple = [0.001 0.001 0.001 0.001 0.001 0.001];
rejection = [90 90 90 90 90 90];

index = 1; filter_names = {};
for test_number = 1:1:length(insertion_loss_at_fc)
    [sos fos k N] = Chebyshev_IIR_Filter_Designer(fc, ...
                                  insertion_loss_at_fc(test_number), ...
                                  transition_region_width(test_number), ...
                                  ripple(test_number), ...
                                  rejection(test_number));

	filter_names{index} = sprintf(['%ddB IL @ Fc Filter with ' ...
                                   '%1.4f transition region width, ' ...
                                   '%1.3fdB ripple, and ' ...
                                   '%ddB rejection. ' ...
                                   'Order %d '], ...
                                   insertion_loss_at_fc(test_number), ...
                                   transition_region_width(test_number), ...
                                   ripple(test_number), ...
                                   rejection(test_number), ...
                                   N);

    %Filter
    sout_iir{index} = custom_filter(s, sos, fos, k);

    %Normalize
    sout_iir{index} = sout_iir{index} ./ max(abs(sout_iir{index}));
    %Dont Normalize If you strictly want the amplitude

    %Calculate powers
    total_power = sum(power(sout_iir{index}, 2));
    for n = 1:1:length(breakpoints)
        fractional_power{index}(n) = ...
            sum(power(sout_iir{index}(1:1:breakpoints(n)), 2)) ...
            / total_power;
    end
    index = index + 1;
end

sout_srrc = conv(h, s);
sout_srrc = sout_srrc ./ max(abs(sout_srrc));
%sout_srrc = sout_srrc(1 + ((length(h) - 1) / 2):end - ((length(h) - 1) / 2));
sout_srrc = sout_srrc(1:end - 2*((length(h) - 1) / 2));

oversampled_sout_iir{size(sout_iir,1),size(sout_iir,2)} = [];
oversampling_filter = fir1(2^12, 1 / (Result_Usampr / USAMPR));
for index = 1:1:size(sout_iir,2)
    temp = 0;
    temp = upsample(sout_iir{index}, Result_Usampr / USAMPR);
    temp = conv(temp, oversampling_filter);
    temp = conv(temp, oversampling_filter);
    oversampled_sout_iir{index} = temp(1 + 2*((length(oversampling_filter) - 1) / 2)...
                                    :end - 2*((length(oversampling_filter) - 1) / 2));
    %Normalize
    oversampled_sout_iir{index} = oversampled_sout_iir{index} ...
                                ./ max(abs(oversampled_sout_iir{index}));
    %Dont Normalize If you strictly want the amplitude
    
end

oversampled_sout_srrc = [];
temp = 0;
temp = upsample(sout_srrc, Result_Usampr / USAMPR);
temp = conv(temp, oversampling_filter);
temp = conv(temp, oversampling_filter);
oversampled_sout_srrc = temp(1 + 2*((length(oversampling_filter) - 1) / 2)...
                          :end - 2*((length(oversampling_filter) - 1) / 2));

%Normalize
oversampled_sout_srrc = oversampled_sout_srrc ...
                            ./ max(abs(oversampled_sout_srrc));
%Dont Normalize If you strictly want the amplitude

xaxis = linspace(1, ...
                 number_of_samples / USAMPR, ...
                 number_of_samples *(Result_Usampr / USAMPR));

figure(1)
hold on
grid on
grid minor
legend_data = [];
LW = {1; 1; 1; 1; 1; 1; 1; 1};
LS = {'-'; '-'; '-'; '-'; '-'; '-'; 'none'; '-.'; '-.'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; ...
      [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; ... %[ 0.3010 0.7450 0.9330]; ...
      [0 0 0]; [0.6350 0.0780 0.1840]};
MS = {'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'o'; 'none'; 'none'};
line_count = 1;
for index = [1 size(filter_names,2)] %1:1:size(filter_names,2)
    plot(xaxis, oversampled_sout_iir{index},'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index})
    legend_data{line_count} = sprintf('IIR %s', filter_names{index});
    line_count = line_count + 1;
end
% plot(xaxis, oversampled_sout_srrc,'LineWidth',LW{index + 1},'LineStyle',LS{index + 1},'Marker',MS{index + 1},'Color',LC{index + 1})
% legend_data{index + 1} = 'SRRC';
title('Filter Impulse Response');
xlabel('Time Normalized To Tsym')
ylabel('Amplitude')

legend(legend_data)
ax = gca;
% ax.YScale = 'log';
% ax.YTick = power(10,-20:1:0);
ax.YGrid = 'on';
ax.YMinorGrid = 'on';

% ax.XScale = 'log';
% ax.XTick = breakpoints;
ax.XGrid = 'on';
ax.XMinorGrid = 'off';
axis([1 220 -1 1])

frequencies = linspace(-(Result_Usampr / 2), ...
                 (Result_Usampr / 2), ...
                 number_of_samples *(Result_Usampr / USAMPR));

figure(2)
hold on
grid on
grid minor
legend_data = [];
LW = {1; 1; 1; 1; 1; 1; 1; 1};
LS = {'-'; '-'; '-'; '-'; '-'; '-'; 'none'; '-.'; '-.'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; ...
      [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; ... %[ 0.3010 0.7450 0.9330]; ...
      [0 0 0]; [0.6350 0.0780 0.1840]};
MS = {'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'o'; 'none'; 'none'};
line_count = 1;
for index = [1 size(filter_names,2)] %1:1:size(filter_names,2)
    plot(frequencies, normalized_frequency_response(oversampled_sout_iir{index}, length(oversampled_sout_iir{index})),'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index}) % nextpow2(length(s))+(nextpow2((Result_Usampr / USAMPR)))-1
    legend_data{line_count} = sprintf('IIR %s', filter_names{index});
    line_count = line_count + 1;
end
% plot(frequencies, normalized_frequency_response(oversampled_sout_srrc, 1024),'LineWidth',LW{index + 1},'LineStyle',LS{index + 1},'Marker',MS{index + 1},'Color',LC{index + 1})
% legend_data{index + 1} = 'SRRC';
title('Frequency Response');
xlabel('Frequency Normalized To Rsym')
ylabel('Magnitude^{2} dB')

legend(legend_data)
ax = gca;
% ax.YScale = 'log';
ax.YTick = -150:10:10;
ax.YGrid = 'on';
ax.YMinorGrid = 'on';

% ax.XScale = 'log';
% ax.XTick = breakpoints;
ax.XGrid = 'on';
ax.XMinorGrid = 'off';
axis([min(frequencies) max(frequencies) -150 10])

figure(3)
hold on
grid on
grid minor
legend_data = [];
LW = {1; 1; 1; 1; 1; 1; 1; 1};
LS = {'-'; '-'; '-'; '-'; '-'; '-'; 'none'; '-.'; '-.'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; ...
      [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; ... %[ 0.3010 0.7450 0.9330]; ...
      [0 0 0]; [0.6350 0.0780 0.1840]};
MS = {'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'o'; 'none'; 'none'};
line_count = 1;
for index = [1 size(filter_names,2)] %1:1:size(filter_names,2)
    plot(frequencies, normalized_frequency_response(oversampled_sout_iir{index}, length(oversampled_sout_iir{index})),'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index}) % nextpow2(length(s))+(nextpow2((Result_Usampr / USAMPR)))-1
    legend_data{line_count} = sprintf('IIR %s', filter_names{index});
    line_count = line_count + 1;
end
% plot(frequencies, normalized_frequency_response(oversampled_sout_srrc, 1024),'LineWidth',LW{index + 1},'LineStyle',LS{index + 1},'Marker',MS{index + 1},'Color',LC{index + 1})
% legend_data{index + 1} = 'SRRC';
title('Frequency Response');
xlabel('Frequency Normalized To Rsym')
ylabel('Magnitude^{2} dB')

legend(legend_data)
ax = gca;
% ax.YScale = 'log';
ax.YTick = -150:10:10;
ax.YGrid = 'on';
ax.YMinorGrid = 'on';

% ax.XScale = 'log';
% ax.XTick = breakpoints;
ax.XGrid = 'on';
ax.XMinorGrid = 'off';
axis([((1 / USAMPR) - 4*transition_region_width(1)) ...
      ((1 / USAMPR) + 4*transition_region_width(1)) -150 10])
