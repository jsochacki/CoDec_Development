function [output] = matlab_awgn_comp(signal, reqSNR_dB)

    reqSNR = power(10, reqSNR_dB/10);
    sigPower = sum(abs(signal).^2)/length(signal);
    noisePower = sigPower/reqSNR;

    if isreal(signal)
       noise = (sqrt(noisePower)) * randn(size(signal,1),1);
    else
       noise = ...
           (sqrt(noisePower/2)) * ...
           (randn(size(signal,1),1) + 1i*randn(size(signal,1),1));
    end;

    output = signal + noise;
end