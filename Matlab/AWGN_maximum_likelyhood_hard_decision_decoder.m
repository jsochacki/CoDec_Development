function [decoded_complex_stream] = ...
                AWGN_maximum_likelyhood_hard_decision_decoder( ...
                    received_baseband_data, ...
                    Constellation, ...
                    complex_mapping)

% First checks data and make sure it is a row vector, if it is not it
% changes it to be one for processing.
% Then we get the euclidean distance between the symbol and all the symbol
% locations in the constellation.
% Then we sort them and check to make sure that the symbol is not
% equidistant from two constellation points.
% If it is not we assign the value of the closest constellation point and
% repeat.
% If it is then we randomly select from one of the two points and repeat.
% Once all the data is processed we put the output vector in the same
% format that the input vector was and are done.

% Constellation and complex_mapping are two different variables to allow
% you to remap on the fly if you want.  If you just make them the same than
% there is mapping to the complex_mapping.

trn=0;
if size(received_baseband_data,1) > size(received_baseband_data,2), received_baseband_data=received_baseband_data.';, trn=1;, end;

decoded_complex_stream=[];

for n=1:1:length(received_baseband_data)
    MAG=[]; IND=[]; EUCDIS=[];
    EUCDIS=(received_baseband_data(1,n)-Constellation).*(received_baseband_data(1,n)-Constellation)'.';
    [MAG IND]=sort(EUCDIS,'ascend');
    if sum(MAG(1)==MAG(2:1:length(MAG)))
        decoded_complex_stream=[decoded_complex_stream randsrc(1,1,complex_mapping(EUCDIS==MAG(1)))];
    else
        decoded_complex_stream=[decoded_complex_stream complex_mapping(IND(1))];
    end
end

if trn, decoded_complex_stream=decoded_complex_stream.';, end;

end