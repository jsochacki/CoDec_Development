function [test_vector] = test_vectors_top_level(test_number)
    switch test_number
        case 1
            filter_variables = {'sos_3dB', 'fos_3dB', 'k_3dB'};
            pn_variables = {};
            EbNo_variables = {};
        case 2
            filter_variables = {'sos_6dB', 'fos_6dB', 'k_6dB'};
            pn_variables = {};
            EbNo_variables = {};
        case 3
            filter_variables = {'sos_9dB', 'fos_9dB', 'k_9dB'};
            pn_variables = {};
            EbNo_variables = {};
        case 4
            filter_variables = {'sos_12dB', 'fos_12dB', 'k_12dB'};
            pn_variables = {};
            EbNo_variables = {};
        case 5
            filter_variables = {'sos_15dB', 'fos_15dB', 'k_15dB'};
            pn_variables = {};
            EbNo_variables = {};
        otherwise
    end
    test_vector = {filter_variables pn_variables EbNo_variables};
end