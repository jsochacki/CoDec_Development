function [test_vector] = test_vectors_top_level(test_number)
    switch test_number
        case 1  %3dB tests
            filter_variables = {'sos_3dB', 'fos_3dB', 'k_3dB'};
            pn_variables = 2^7;
        case 2
            filter_variables = {'sos_3dB', 'fos_3dB', 'k_3dB'};
            pn_variables = 2^10;
        case 3
            filter_variables = {'sos_3dB', 'fos_3dB', 'k_3dB'};
            pn_variables = 2^13;
        case 4
            filter_variables = {'sos_3dB', 'fos_3dB', 'k_3dB'};
            pn_variables = 2^16;
        case 5  %6dB tests
            filter_variables = {'sos_6dB', 'fos_6dB', 'k_6dB'};
            pn_variables = 2^7;
        case 6
            filter_variables = {'sos_6dB', 'fos_6dB', 'k_6dB'};
            pn_variables = 2^10;
        case 7
            filter_variables = {'sos_6dB', 'fos_6dB', 'k_6dB'};
            pn_variables = 2^13;
        case 8
            filter_variables = {'sos_6dB', 'fos_6dB', 'k_6dB'};
            pn_variables = 2^16;
        case 9  %9dB tests
            filter_variables = {'sos_9dB', 'fos_9dB', 'k_9dB'};
            pn_variables = 2^7;
        case 10
            filter_variables = {'sos_9dB', 'fos_9dB', 'k_9dB'};
            pn_variables = 2^10;
        case 11
            filter_variables = {'sos_9dB', 'fos_9dB', 'k_9dB'};
            pn_variables = 2^13;
        case 12
            filter_variables = {'sos_9dB', 'fos_9dB', 'k_9dB'};
            pn_variables = 2^16;
        case 13  %12dB tests
            filter_variables = {'sos_12dB', 'fos_12dB', 'k_12dB'};
            pn_variables = 2^7;
        case 14
            filter_variables = {'sos_12dB', 'fos_12dB', 'k_12dB'};
            pn_variables = 2^10;
        case 15
            filter_variables = {'sos_12dB', 'fos_12dB', 'k_12dB'};
            pn_variables = 2^13;
        case 16
            filter_variables = {'sos_12dB', 'fos_12dB', 'k_12dB'};
            pn_variables = 2^16;
        case 17  %15dB tests
            filter_variables = {'sos_15dB', 'fos_15dB', 'k_15dB'};
            pn_variables = 2^7;
        case 18
            filter_variables = {'sos_15dB', 'fos_15dB', 'k_15dB'};
            pn_variables = 2^10;
        case 19
            filter_variables = {'sos_15dB', 'fos_15dB', 'k_15dB'};
            pn_variables = 2^13;
        case 20
            filter_variables = {'sos_15dB', 'fos_15dB', 'k_15dB'};
            pn_variables = 2^16;
        otherwise
    end
    EbNo_variables = 0.5:0.05:1.5;
    BER_variables = [0.0671379089355469, ...
                     0.0659877777099609, ...
                     0.0648143768310547, ...
                     0.0639659881591797, ...
                     0.0626415252685547, ...
                     0.0614763259887695, ...
                     0.0606014251708984, ...
                     0.0595701217651367, ...
                     0.0582939147949219, ...
                     0.0571819305419922, ...
                     0.0562868118286133, ...
                     0.0551664352416992, ...
                     0.0543579101562500, ...
                     0.0532655715942383, ...
                     0.0521432876586914, ...
                     0.0513214111328125, ...
                     0.0501516342163086, ...
                     0.0493051528930664, ...
                     0.0484533309936523, ...
                     0.0474143981933594, ...
                     0.0463769912719727];
    test_vector = {filter_variables pn_variables EbNo_variables BER_variables};
end