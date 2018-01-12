clear all

fc = 0.25;
insertion_loss_at_fc = 3;
transition_region_width = 0.02;
ripple = 0.001; %ripple in dB
rejection = 60; %rejection in dB

[sos fos k N] = Chebyshev_IIR_Filter_Designer(fc, ...
                                              insertion_loss_at_fc, ...
                                              transition_region_width, ...
                                              ripple, ...
                                              rejection);
data = [zeros(1,512) 1 zeros(1,512)];
[filtered_signal] = custom_filter(data, sos, fos, k)
plot(20*log10(abs(fftshift(fft(filtered_signal, length(filtered_signal))))))

fvtool(filtered_signal)
[filtered_signal] = custom_filter(fliplr(filtered_signal), sos, fos, k)
plot(20*log10(abs(fftshift(fft(filtered_signal, length(filtered_signal))))))

fvtool(filtered_signal)