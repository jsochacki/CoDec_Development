EbN0dB=-4:1:24;
EbN0lin=10.^(EbN0dB/10);
colors={'b-*','g-o','r-h','c-s','m-d','y-*','k-p','b--','g','r-.d'};
index=1;

%BPSK
BPSK = 0.5*erfc(sqrt(EbN0lin));
plotHandle=plot(EbN0dB,log10(BPSK),char(colors(index)));
set(plotHandle,'LineWidth',1.5);
hold on;

index=index+1;

%M-PSK
m=2:1:5;
M=2.^m;
for i=M,
    k=log2(i);
    berErr = 1/k*erfc(sqrt(EbN0lin*k)*sin(pi/i));
    plotHandle=plot(EbN0dB,log10(berErr),char(colors(index)));
    set(plotHandle,'LineWidth',1.5);
    index=index+1;
end

%Binary DPSK
Pb = 0.5*exp(-EbN0lin);
plotHandle = plot(EbN0dB,log10(Pb),char(colors(index)));
set(plotHandle,'LineWidth',1.5);
index=index+1;

%Differential QPSK
a=sqrt(2*EbN0lin*(1-sqrt(1/2)));
b=sqrt(2*EbN0lin*(1+sqrt(1/2)));
Pb = marcumq(a,b,1)-1/2.*besseli(0,a.*b).*exp(-1/2*(a.^2+b.^2));
plotHandle = plot(EbN0dB,log10(Pb),char(colors(index)));
set(plotHandle,'LineWidth',1.5);
index=index+1;

%M-QAM
m=2:2:6;
M=2.^m;

for i=M,
    k=log2(i);
    berErr = 2/k*(1-1/sqrt(i))*erfc(sqrt(3*EbN0lin*k/(2*(i-1))));
    plotHandle=plot(EbN0dB,log10(berErr),char(colors(index)));
    set(plotHandle,'LineWidth',1.5);
    index=index+1;
end

legend('BPSK','QPSK','8-PSK','16-PSK','32-PSK','D-BPSK','D-QPSK','4-QAM','16-QAM','64-QAM');
axis([-4 24 -8 0]);
set(gca,'XTick',-4:2:24); %re-name axis accordingly
ylabel('Probability of BER Error - log10(Pb)');
xlabel('Eb/N0 (dB)');
title('Probability of BER Error log10(Pb) Vs Eb/N0');
grid on;