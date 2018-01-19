function [output_after_agc] = AGC2(signal, desired_sum_squared_power, ringud)
%msp = @(x) (1/length(x)) * sum(x .* x'.');
%A = msp(signal);

a_signal = signal((1+(ringud)):1:(end-(ringud)));

A = (1/length(a_signal)) * sum(a_signal .* conj(a_signal));
output_after_agc = signal / sqrt(A / desired_sum_squared_power);

end