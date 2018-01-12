clear all

%%% We make a tone that is 1 complete cycle so there is no spectral leakage
step_size = 1e-3; phase_offset = pi/4; magnitude = 1;
t = 0:step_size:1-step_size; vector_length = length(t);
tone = magnitude * exp((j * 2 * pi * t) + (j * phase_offset));

%%% Tone power should be :
%%%      cos(x) =>
%%%      (1 [peak amplitude in volts]
%%%       * 1 / sqrt(2) [convertion to VRMS]) ^ 2
%%%      exp(x) => (as exp(x) = cos(x) + j*sin(x))
%%%      (1 [VRMS]) ^ 2 (as the magnitude of sxp is constant and therefore
%%%      equal to it's RMS value as well
%%% As VRMS squared / R (Here R is assumed to be 1) is the power in watts
%%% Here this is 1 Watts or 10*log10(1/0.001) = 30 dBm
tonePowerFromTime = (tone * tone') / length(tone);

toneFFT = power(fftshift(abs(fft(tone,length(tone)))/length(tone)),2);
tonePowerFromFFT = sum(toneFFT);
plot(10*log10(toneFFT/0.001))

%%% 100% accuracy so now lets look at a reduction in the FFT length
vectortonePowerFromFFT = [];
vectortoneValueFromFFT = [];
vectortoneMagFromFFT = [];
vectortoneAngleFromFFT = [];
for FFTSIZE = 1:1:12
    toneFFT = fftshift((fft(tone,(2^FFTSIZE)))/(2^FFTSIZE));
    tone_index = find((abs(toneFFT)) == max(abs(toneFFT)));
    tone_index = tone_index(1);
    vectortoneMagFromFFT = [vectortoneMagFromFFT ...
                sqrt(toneFFT(tone_index) .* toneFFT(tone_index)')];
    angletoneFFT = (180 / pi)* unwrap(angle(toneFFT));
    vectortoneAngleFromFFT = [vectortoneAngleFromFFT ...
                angletoneFFT(tone_index)];
    vectortonePowerFromFFT = [vectortonePowerFromFFT sum(power(abs(toneFFT),2))];
    vectortoneValueFromFFT = [vectortoneValueFromFFT ...
                        10*log10(power(max(abs(toneFFT)), 2) / 0.001)];
end
magnitude_error = magnitude - vectortoneMagFromFFT;
magnitude_error_in_dB = 20*log10(magnitude./vectortoneMagFromFFT);
phase_error = vectortoneAngleFromFFT - (phase_offset * (180 / pi));

%%% If we look at vectortoneValueFromFFT we can see the following
%%% 1) for very large FFT values the power drops off.  This is because the
%%% function zero pads the vector that you feed it so that it can do a FFT
%%% and therefore the vecotor is now effectively a zero value vector so
%%% what we see is what we should see
%%% 2)For FFT Lengths greater than the vector length you quickly lose
%%% accuracy.
%%% 3)Because the signal is super oversampled in the time domain, using
%%% smaller values for the FFT does not affect the result as you are
%%% throwing out samples for the vector to be processed that just don't
%%% matter
%%% 4)Although the summation of the values in the FFT is accurate for a
%%% total power measurement for an FFT length up to that of the signal, the
%%% value of the tone starts to become inaccurate 
plot(10*log10(power((abs(toneFFT)), 2) / 0.001))


step_size = 1e-2;
t = 0:step_size:1-step_size; vector_length = length(t);
tone = exp((j * 2 * pi * t) + (j * pi/4));
tonePowerFromTime = (tone * tone') / length(tone);
toneFFT = power(fftshift(abs(fft(tone,length(tone)))/length(tone)),2);
tonePowerFromFFT = sum(toneFFT);
plot(10*log10(toneFFT/0.001))

%%% 100% accuracy so now lets look at a reduction in the FFT length
vectortonePowerFromFFT = [];
vectortoneValueFromFFT = [];
vectortoneMagFromFFT = [];
vectortoneAngleFromFFT = [];
for FFTSIZE = 1:1:8
    toneFFT = fftshift((fft(tone,(2^FFTSIZE)))/(2^FFTSIZE));
    tone_index = find((abs(toneFFT)) == max(abs(toneFFT)));
    tone_index = tone_index(1);
    vectortoneMagFromFFT = [vectortoneMagFromFFT ...
                sqrt(toneFFT(tone_index) .* toneFFT(tone_index)')];
    angletoneFFT = (180 / pi)* unwrap(angle(toneFFT));
    vectortoneAngleFromFFT = [vectortoneAngleFromFFT ...
                angletoneFFT(tone_index)];
    vectortonePowerFromFFT = [vectortonePowerFromFFT sum(power(abs(toneFFT),2))];
    vectortoneValueFromFFT = [vectortoneValueFromFFT ...
                        10*log10(power(max(abs(toneFFT)), 2) / 0.001)];
end
magnitude_error = magnitude - vectortoneMagFromFFT;
magnitude_error_in_dB = 20*log10(magnitude./vectortoneMagFromFFT);
phase_error = vectortoneAngleFromFFT - (phase_offset * (180 / pi));

%%% Ok, so now that we have seen what we can expect we really want to make
%%% sure that we have the proper oversampling to FFT size ratio for the
%%% accuracy that we are specifying, which by the way, what is that?  What
%%% is the accuracy we want in dB and angle?  For now I will assume we want
%%% measurements to within a 0.1 dB and 0.1 degrees

%%% In the actual application we are sampling at 1000Msps and we are
%%% looking at a channel of 500MHz so we are have 2x oversampling upwards
%%% (the upwards means that we can look at a smaller bandwidth if we want
%%% to).  Taking the max of this we would look at say 1 MHz of bandwidth at
%%% a minimum so we will be up to 1000x oversampled

%%% So looking at the heavily oversampled case we can see that the error is
%%% best for the smallest FFT size and the it increases as you increase the
%%% FFT size to the length of the signal you are FFTing and then beyond
over_sampling_rate = 1000;
step_size = (1/(2 * over_sampling_rate));
t = 0:step_size:1-step_size; vector_length = length(t);
tone = exp((j * 2 * pi * t) + (j * pi/4));

magnitude_error_in_dB = []; phase_error = [];
for FFTSIZE = 1:1:14
    toneFFT = fftshift((fft(tone,(2^FFTSIZE)))/(2^FFTSIZE));
    tone_index = find((abs(toneFFT)) == max(abs(toneFFT)));
    tone_index = tone_index(1);
    angletoneFFT = (180 / pi)* unwrap(angle(toneFFT));

    magnitude_error_in_dB = [magnitude_error_in_dB ...
                    20*log10(magnitude./...
                    sqrt(toneFFT(tone_index) .* toneFFT(tone_index)'))];
    phase_error = [phase_error ...
                angletoneFFT(tone_index) - (phase_offset * (180 / pi))];

end

%%% So looking at the notheavily oversampled case we can see that the error
%%% is sort of hard to predect and see what is going on but in gerenal when
%%% the FFT size is equal to that of the vector you are accurate, otherwise
%%% you can have signifigant phase error with no amplitude error
over_sampling_rate = 17;
step_size = (1/(2 * over_sampling_rate));
t = 0:step_size:1-step_size; vector_length = length(t);
tone = exp((j * 2 * pi * t) + (j * pi/4));

magnitude_error_in_dB = []; phase_error = [];
for FFTSIZE = 1:1:14
    toneFFT = fftshift((fft(tone,(2^FFTSIZE)))/(2^FFTSIZE));
    tone_index = find((abs(toneFFT)) == max(abs(toneFFT)));
    tone_index = tone_index(1);
    angletoneFFT = (180 / pi)* unwrap(angle(toneFFT));

    magnitude_error_in_dB = [magnitude_error_in_dB ...
                    20*log10(magnitude./...
                    sqrt(toneFFT(tone_index) .* toneFFT(tone_index)'))];
    phase_error = [phase_error ...
                angletoneFFT(tone_index) - (phase_offset * (180 / pi))];

end

%%% So instead lets look at the minimum order FFT where we can achieve the
%%% accuracy that we need vs sampling rate and see what happens
over_sampling_rate = 1;
FFTSizes = [];
while over_sampling_rate <=1000
    magnitude_error_in_dB = [];
    phase_error = [];
    step_size = (1/(2 * over_sampling_rate));
    t = 0:step_size:1-step_size; vector_length = length(t);
    tone = exp((j * 2 * pi * t) + (j * pi/4));
    for FFTSIZE = 1:1:14
        toneFFT = fftshift((fft(tone,(2^FFTSIZE)))/(2^FFTSIZE));
        tone_index = find((abs(toneFFT)) == max(abs(toneFFT)));
        tone_index = tone_index(1);
        angletoneFFT = (180 / pi)* unwrap(angle(toneFFT));

        magnitude_error_in_dB = [magnitude_error_in_dB ...
                        20*log10(magnitude./...
                        sqrt(toneFFT(tone_index) .* toneFFT(tone_index)'))];
        phase_error = [phase_error ...
                    angletoneFFT(tone_index) - (phase_offset * (180 / pi))];

    end
    FFTSizes = [FFTSizes ...
        max([max(find(abs(phase_error) < 0.1)) ...
        max(find(magnitude_error_in_dB < 0.1))])];
    over_sampling_rate = over_sampling_rate + 1;
end
plot(FFTSizes)

x = find(FFTSizes < 14);
GoodRatios = FFTSizes(x);
plot(x, GoodRatios)
semilogx(x, GoodRatios)

BadRatios = find(FFTSizes == 14);
