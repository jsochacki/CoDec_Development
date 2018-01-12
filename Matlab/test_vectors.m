function [vector] = test_vectors(test_number)
    switch test_number
        case 1
            fc = 0.25;
            insertion_loss_at_fc = 3;
            transition_region_width = 0.02;
            ripple = 0.001; %ripple in dB
            rejection = 60; %rejection in dB
            vector = [fc ...
                      insertion_loss_at_fc ...
                      transition_region_width ...
                      ripple ...
                      rejection];
        otherwise
    end
end