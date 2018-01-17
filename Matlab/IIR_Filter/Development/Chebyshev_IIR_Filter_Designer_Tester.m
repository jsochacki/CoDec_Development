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

if isvector(fos)
    atot = [fos(1, 3) fos(1, 4)];
    btot = [fos(1, 1) fos(1, 2)];
    start_index = 1;
else
    atot = [sos(1, 4) sos(1, 5) sos(1, 6)];
    btot = [sos(1, 1) sos(1, 2) sos(1, 3)];
    start_index = 2;
end
 
for i = start_index:1:size(sos,1)
    atot = conv(atot, [sos(i, 4) sos(i, 5) sos(i, 6)]);
    btot = conv(btot, [sos(i, 1) sos(i, 2) sos(i, 3)]);
end

fvtool(k*btot,atot)

atot = conv(atot, atot);
btot = conv(btot, btot);

fvtool(k*k*btot,atot)
