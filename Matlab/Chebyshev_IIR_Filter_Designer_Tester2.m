clear all

fc = 0.25;
insertion_loss_at_fc = 3;
% Should be less than alpha = 0.1, 0.0125 is goal for 60dB
transition_region_width = 0.0125;
ripple = 0.001; %ripple in dB
rejection = 90; %rejection in dB

[sos fos k N] = Chebyshev_IIR_Filter_Designer(fc, ...
                                              insertion_loss_at_fc, ...
                                              transition_region_width, ...
                                              ripple, ...
                                              rejection);

impulse_length = (2^16) + 1;

data = [zeros(1, (impulse_length - 1)/2) 1 zeros(1, (impulse_length - 1)/2)];
[filtered_signal] = custom_filter(data, sos, fos, k);
%plot(20*log10(abs(fftshift(fft(filtered_signal, length(filtered_signal))))))
frequency_response = 20*log10(abs((fft(filtered_signal, length(filtered_signal)))));
positive_frequency_response = frequency_response(1:1:((impulse_length + 1) / 2));
fc_index = length(positive_frequency_response) * 2 * fc;
transition_region_end_index = length(positive_frequency_response) * ...
                              ( (2 * fc) + ...
                                (2 * transition_region_width / 2) );

positive_frequency_response(ceil(fc_index))
positive_frequency_response(ceil(transition_region_end_index))

%plot(frequency_response(1:1:((impulse_length + 1) / 2)))

fvtool(filtered_signal)

[filtered_signal] = custom_filter(fliplr(filtered_signal), sos, fos, k);
%plot(20*log10(abs(fftshift(fft(filtered_signal, length(filtered_signal))))))

fvtool(filtered_signal)

%Write to a file
save('filter_coefficients.mat','sos_3dB','fos_3dB','k_3dB','-append')