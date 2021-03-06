function [signal_with_awgn] = AWNG_Generator(signal, ...
                                             EbNo_dB, ...
                                             USAMPR, ...
                                             h, ...
                                             BITS_PER_WORD)

trn_signal=0;
if size(signal,1) < size(signal,2), trn_signal=1; signal=signal.';, end;

ringless = [];
CHOPNP = (length(h)-1) / 2;
ringless = signal((1+(CHOPNP)):1:(end-(CHOPNP)));
EbNo = power(10, EbNo_dB / 10);
SNR = EbNo*BITS_PER_WORD/USAMPR;
%RMS Power squared i.e. mean squared power
mssp = (1 / length(ringless)) * (sum(ringless .* conj(ringless)));
N0 = mssp / SNR;
%randn is a uniform random signal generator with mean=0 and
%unit variance (i.e. var = std ^2 therefor also std=1)
%also since it is unit variance, x*randn has a stx=x and var=x^2
%also for real systems var=No and for complex systems var=No/2
if isreal(signal)
    sigma = sqrt(N0);
    Addative_White_Gaussian_Noise = sigma*randn(size(signal,1), 1);
else
    sigma = sqrt(N0/2);
    Addative_White_Gaussian_Noise = ...
        sigma*randn(size(signal,1), 1) + i*sigma*randn(size(signal,1), 1);
end
signal_with_awgn = ...
    signal + Addative_White_Gaussian_Noise;

if trn_signal, signal_with_awgn = signal_with_awgn.';, end;

end