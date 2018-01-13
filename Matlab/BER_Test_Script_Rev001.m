
variables_3dB = {'sos_3dB', 'fos_3dB', 'k_3dB'};

test_variables = load('filter_coefficients.mat',variables_3dB{:})

%Access is done dynamically in the following manner
test_variables.(variables_3dB{1})