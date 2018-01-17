M = 4; % Alphabet size
EbN0_min=0;EbN0_max=10;step=0.1;
SNR=[];SER=[];
for EbN0 = EbN0_min:step:EbN0_max
    SNR_dB=EbN0 + 3; %for QPSK Eb/N0=0.5*Es/N0=0.5*SNR
    if EbN0 > 8
        NumberOfSymbols = 10000000;
    else
        NumberOfSymbols = 1000000;
    end
    x = randint(NumberOfSymbols,1,M);
    y=modulate(modem.qammod(M),x);
    ynoisy = awgn(y,SNR_dB,'measured');
    z=demodulate(modem.qamdemod(M),ynoisy);
    [num,rt]= symerr(x,z);
    SNR=[SNR EbN0];
    SER=[SER rt];
end;
semilogy(SNR,SER);grid;title('Symbol error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)');ylabel('SER')

EbN0 = EbN0_min:step:EbN0_max;
matlab_BER = berawgn(EbN0, 'psk', M, 'nondiff');

hold off
figure(2)
semilogy(EbN0,matlab_BER);grid;title('Bit error rate for QPSK over Stationary AWGN Channel');
xlabel('Eb/No (dB)');ylabel('BER')