function [test_vector] = test_vectors_initial_filter_test_only(test_number)
    switch test_number
        case 1
            filter_variables = {'sos_3dB', 'fos_3dB', 'k_3dB'};
        case 2
            filter_variables = {'sos_6dB', 'fos_6dB', 'k_6dB'};
        case 3
            filter_variables = {'sos_9dB', 'fos_9dB', 'k_9dB'};
        case 4
            filter_variables = {'sos_12dB', 'fos_12dB', 'k_12dB'};
        case 5
            filter_variables = {'sos_15dB', 'fos_15dB', 'k_15dB'};
        otherwise
    end
    test_vector = filter_variables;
end