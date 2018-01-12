clear all

%2^7-1 = 127
Frame_Length = 125000;    % repeated truncated sequence length
PnPoly = [7 3 0];               % > 7dB, good stddev
%PnPoly = [7 3 2 1 0];          % >15dB
%PnPoly = [7 6 5 4 2 1 0];      % >15, but stddev is small
%PnPoly = [7 4 3 2 0];          % >10dB
%PnPoly = [7 5 4 3 2 1 0];      % >14dB
%PnPoly = [7 6 4 2 0];          % >15dB
%PnPoly = [7 1 0];              % >12dB
%PnPoly = [7 6 3 1 0];          % >12dB
%PnPoly = [7 6 5 2 0];          % >12dB

PNLength = (2^7) - 1;         % PN length based on generator polynomial
PnInit = [0 0 0 0 0 1 0];

% PnPoly = [53 6 2 1 0];
% PnInit = [zeros(1,52) 1];
pn = comm.PNSequence('Polynomial',PnPoly,'InitialConditions',PnInit,'SamplesPerFrame',Frame_Length);
x1 = step(pn);     % create single repetition of PN sequence
x1 = x1*2-1;       % convert to +/-1 sequence

%%% Calculate run length metrics
%%% START
one_shot = (x1(1:PNLength) + 1) / 2;
%%% Deal with Zero Runs
zero_runs = one_shot.*(1:1:length(one_shot)).';
run_indicies = find(zero_runs > 0);
zero_runs = diff([0; zero_runs(run_indicies); 128])-1;
run_indicies = find(zero_runs > 0);
zero_runs = sort(zero_runs(run_indicies));
zero_runs_count = [];
for n = 1:1:max(zero_runs)
    zero_runs_count(n) = sum(zero_runs(find(zero_runs == n))) / n;
end
%%% Deal with Ones Runs
one_runs = -(one_shot - 1).*(1:1:length(one_shot)).';
run_indicies = find(one_runs > 0);
one_runs = diff([0; one_runs(run_indicies); 128])-1;
run_indicies = find(one_runs > 0);
one_runs = sort(one_runs(run_indicies));
one_runs_count = [];
for n = 1:1:max(one_runs)
    one_runs_count(n) = sum(one_runs(find(one_runs == n))) / n;
end

%%% Look at runs on a whole
total_runs_count = [];
if length(one_runs_count) > length(zero_runs_count)
    total_runs_count = [zero_runs_count ...
                        zeros(1,length(one_runs_count) - ...
                        length(zero_runs_count))] + one_runs_count;
else
    total_runs_count = [one_runs_count ...
                        zeros(1,length(zero_runs_count) - ...
                        length(one_runs_count))] + zero_runs_count;
end

%%% Make sure runs total pn length and calculate ratios
length_check = 0; runs = 0;
for n = 1:1:length(total_runs_count)
    length_check = length_check + total_runs_count(n) .* n;
    runs = runs + total_runs_count(n);
end
if length_check ~= PNLength
    error('Didn''t do run check properly');
end
ratios = [];
for n = 1:1:length(total_runs_count)
    ratios = [ratios total_runs_count(n) / runs];
    %%% Don't want to error on lots of 1 length runs and cant expect ratio
    %%% to hold for n that gives pn length
    if (ratios(n) > (1 / power(2, n))) & (n > 1) & (n < length(total_runs_count))
        error('Bad PN Code run characteristics @ %d', n);
    end
end
%%% END
%%% Calculate run length metrics

% Sample_Size = 0;
% mean_standard_deviation = [];
% for Sample_Size = 1:1:10 %They all go to 1 virtually for larger chunk sizes
%     temp = 0; count = 0;
%     for n = Sample_Size:Sample_Size:length(x1)
%         temp = temp + std(x1(((n - Sample_Size) + 1):n));
%         count = count + 1;
%     end
%     %%% I think you want to ignore this so it doesn't skew due to non
%     %%% sample size result although you will start ignoring a large portion
%     %%% of the pn code if you just do it on the PN code alone so you
%     %%% probably want to generate a PN code and append it to its self
%     %%% several times and then do this test on that and keep the part below
%     %%% commented out.
% %     if n < length(x1)
% %         temp = temp + std(x1(n:end));
% %         count = count + 1;
% %     end
% mean_standard_deviation = [mean_standard_deviation (temp / count)];
% end

PN = x1;

%%% Look at symmetry
sum_zero = sum(PN == -1);
sum_one = sum(PN == 1);
zero_ratio = sum_zero / (sum_one + sum_zero);
one_ratio = sum_one / (sum_one + sum_zero);
bias = 1 - (sum_zero / sum_one);

series = [PN; PN];

APN = upsample(PN(1:PNLength),5);
r = upsample(series,5);
hmf = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; %ones(5,1);

r_mf = fftfilt(hmf,r);
metric = fftfilt(flipud(APN),r_mf);

relative_metric = metric / PNLength;

peak_dB = 20*log10(max(abs(relative_metric)));

threshold_dB = 10;
threshold = power(10,(peak_dB - threshold_dB)/20);

peaks = find(relative_metric > threshold);

one_step = []; two_steps = []; three_steps = [];
one_step = peak_dB - ...
    20*log10(abs((relative_metric(peaks-1) + relative_metric(peaks+1)) / 2));
two_steps = peak_dB - ...
    20*log10(abs((relative_metric(peaks-2) + relative_metric(peaks+2)) / 2));
three_steps = peak_dB - ...
    20*log10(abs((relative_metric(peaks-3) + relative_metric(peaks+3)) / 2));

relative_metric(peaks) = [];

distance_dB = peak_dB - 20*log10(mean(abs(relative_metric)))
