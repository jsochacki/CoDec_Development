clear all

%%% This is a script to generate the impulse response for an IIR filter and
%%% some metrics associated with it

USAMPR = 2;

%SRRC Filter for Comparison
NSYMBOLS_LONG_FILTER = 120; ORDER = USAMPR * NSYMBOLS_LONG_FILTER;
ROLLOFF = 0.1; SYMBOL_RATE = 1; Fc = SYMBOL_RATE / 2;
h = firrcos(ORDER, Fc, ROLLOFF, USAMPR, 'rolloff', 'sqrt');

number_of_samples = 2^12;
breakpoints = power(2,1:1:12);

%%% Sequence Generation
s = [1 zeros(1, number_of_samples - 1)];

index = 1; filter_names = {};
for test_number = 1%:4:20
    %IIR Filter
    test_vector = test_vectors_top_level(test_number);
    test_variables = load('filter_coefficients.mat', test_vector{1}{:});
    %Access is done dynamically in the following manner
    sos = test_variables.(test_vector{1}{1});
    fos = test_variables.(test_vector{1}{2});
    k = test_variables.(test_vector{1}{3});

    IIR_filter_type = strsplit(test_vector{1}{1}, '_');
    filter_names{index} = IIR_filter_type{2};
    
    %Filter
    sout_iir{index} = custom_filter(s, sos, fos, k);

    %Normalize
    sout_iir{index} = sout_iir{index} ./ max(abs(sout_iir{index}));

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
sout_srrc = sout_srrc(1 + ((length(h) - 1) / 2):end - ((length(h) - 1) / 2));

xaxis = linspace(1,number_of_samples,number_of_samples);

figure(1)
hold on
grid on
grid minor
legend_data = [];
LW = {1; 1; 1; 1; 1; 2; 2; 2};
LS = {'-'; '-'; '-'; '-'; '-'; '-'; 'none'; '-.'; '-.'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; ...
      [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; ... %[ 0.3010 0.7450 0.9330]; ...
      [0 0 0]; [0.6350 0.0780 0.1840]};
MS = {'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'o'; 'none'; 'none'};
for index = 1:1:size(filter_names,2)
    plot(xaxis - 1, power(sout_iir{index}, 2),'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index})
    legend_data{index} = sprintf('IIR %s Filter', filter_names{index});
end
plot(xaxis - 1, power(sout_srrc, 2),'LineWidth',LW{index + 1},'LineStyle',LS{index + 1},'Marker',MS{index + 1},'Color',LC{index + 1})
legend_data{index + 1} = 'SRRC';
title('Filter Impulse Responses');
xlabel('Sample Number After Impulse')
ylabel('Squared Magnitude')

legend(legend_data)
ax = gca;
ax.YScale = 'log';
ax.YTick = power(10,-20:1:0);
ax.YGrid = 'on';
ax.YMinorGrid = 'on';

ax.XScale = 'log';
ax.XTick = breakpoints;
ax.XGrid = 'on';
ax.XMinorGrid = 'off';
axis([1 length(s) 1e-20 1])


figure(2)
hold on
grid on
grid minor
legend_data = [];
LW = {1; 1; 1; 1; 1; 1; 2; 2};
LS = {'-'; '-'; '-'; '-'; '-'; '-'; 'none'; '-.'; '-.'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; ...
      [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; ... %[ 0.3010 0.7450 0.9330]; ...
      [0 0 0]; [0.6350 0.0780 0.1840]};
MS = {'none'; 'none'; 'none'; 'none'; 'none'; 'none'; 'o'; 'none'; 'none'};
for index = 1:1:size(filter_names,2)
    plot(breakpoints, fractional_power{index},'LineWidth',LW{index},'LineStyle',LS{index},'Marker',MS{index},'Color',LC{index})
    legend_data{index} = sprintf('IIR %s Filter', filter_names{index});
end
plot(xaxis - 1, power(sout_iir{1}, 2),'LineWidth',LW{index + 1},'LineStyle',LS{index + 1},'Marker',MS{index + 1},'Color',LC{index + 1})
legend_data{index + 1} = sprintf('IIR %s Filter', filter_names{1});
title('Percent IIR Filter Power Per Sample Number Offset');
xlabel('Sample Number After Impulse')
ylabel('IIR Filter Power Relative To Total Filter Power')

legend(legend_data)
ax = gca;
ax.YScale = 'log';
ax.YTick = power(10,-20:1:0);
ax.YGrid = 'on';
ax.YMinorGrid = 'on';

ax.XScale = 'log';
ax.XTick = breakpoints;
ax.XGrid = 'on';
ax.XMinorGrid = 'off';
axis([1 length(s) 1e-20 1])
