clear all

load('Results\BER_Test_Script_Rev004_20_averages_test_number_1_Results.mat')

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
axis([min(EbNo_vec) max(EbNo_vec) 1e-6 1e-1])
