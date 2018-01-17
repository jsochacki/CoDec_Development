function [output_after_agc] = AGC(signal, desired_sum_squared_power)
%msp = @(x) (1/length(x)) * sum(x .* x'.');
%A = msp(signal);

A = (1/length(signal)) * sum(signal .* conj(signal));
output_after_agc = signal / sqrt(A / desired_sum_squared_power);

end