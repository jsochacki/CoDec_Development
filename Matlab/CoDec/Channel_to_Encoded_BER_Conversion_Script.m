clear all

data_path = 'J:\BHD\ViaSat\Proposals\Business\DARPA\Warped_Wing\Mine\CoDec_Development\Matlab\CoDec\Results\';
data_file = 'Channel_BER_vs_Encoded_BER_clipping_value_3.txt';

data = csvread(fullfile(data_path, data_file));

EbNo = data(:,1);
channel_BER = data(:,2);
Encoded_BER = data(:,3);

figure(1)
hold on
grid on
grid minor
legend_data = [];
LS = {'-';'-.';':';':';':';':';':';':'};
MS = {'.';'none';'-.';':';':';':';':';':';':'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]};
semilogy(channel_BER, Encoded_BER,'LineWidth',1,'LineStyle',LS{1},'Marker',MS{1},'Color',LC{1},'MarkerEdgeColor',LC{2}, 'MarkerSize',10)
%legend_data{1} = 'Simulation';
title({'QPSK Encoded Bit Error Rate vs Channel Bit Error Rate',...
       'Over Stationary AWGN Channel with clipping level = 1'});
xlabel('Channel BER')
ylabel('Encoded BER')

%legend(legend_data)
ax = gca;
ax.YScale = 'log';
ax.XScale = 'linear';
ax.XTickMode = 'manual'
ax.XTick = flipud(channel_BER);
ax.YTickMode = 'manual'
ax.YTick = logspace(-8,0,9);
ax.XMinorTick = 'on'
axis([min(flipud(channel_BER)) max(flipud(channel_BER)) 1e-8 1])

figure(2)
hold on
grid on
grid minor
legend_data = [];
LS = {'-';'-.';':';':';':';':';':';':'};
MS = {'.';'none';'-.';':';':';':';':';':';':'};
LC = {[0 0.4470 0.7410]; [ 0.8500 0.3250 0.0980]; [ 0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]};
semilogy(EbNo, Encoded_BER,'LineWidth',1,'LineStyle',LS{1},'Marker',MS{1},'Color',LC{1},'MarkerEdgeColor',LC{2}, 'MarkerSize',10)
%legend_data{1} = 'Simulation';
title({'QPSK Encoded Bit Error Rate Over Stationary AWGN Channel',...
       'clipping level = 1'});
xlabel('Eb/No (dB)')
ylabel('Encoded BER')

%legend(legend_data)
ax = gca;
ax.YScale = 'log';
ax.XScale = 'linear';
ax.XTickMode = 'manual'
ax.XTick = [min(EbNo)-0.05;EbNo;max(EbNo)+0.05];
ax.YTickMode = 'manual'
ax.YTick = logspace(-8,0,9);
ax.XMinorTick = 'on'
axis([min(EbNo)-0.05 max(EbNo)+0.05 1e-8 1])