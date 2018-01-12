function [filtered_signal] = custom_filter(data, sos, fos, k)
    if isvector(fos)
        %%% Apply a portion of the gain with each filtering application
        %%% Here there are sos + 1 (for the fos) stages
        Nstages = size(sos,1) + 1;
        kk = power(k,1/Nstages);
        filtered_signal = kk*filter(fos(1, 1:1:2),fos(1, 3:1:4),data);
        for i = 1:1:size(sos, 1)
            filtered_signal = kk*filter(sos(i, 1:1:3),sos(i, 4:1:6),filtered_signal);
        end
    else
        Nstages = size(sos,1);
        kk = power(k,1/Nstages);
        filtered_signal = data;
        for i = 1:1:size(sos, 1)
            filtered_signal = kk*filter(sos(i, 1:1:3),sos(i, 4:1:6),filtered_signal);
        end
    end
end