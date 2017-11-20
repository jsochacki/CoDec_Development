function [data_out ERROR checksum_value] = check_crc(data_in, polynomial)

%This has been verified as correct and functional when compared to the
%DVBS2 manual and the online checksum calculator @ http://crccalc.com/

    if ischar(polynomial)
        polynomial = get_crc_polynomial(polynomial);
    end

    %Transfer so you can keep the actual data you want
    checkdata = data_in;

    start = 1;
    while start <= (length(checkdata) - (length(polynomial) - 1))
        if checkdata(start) ~= 1
            start = start + 1;
        else
            checkdata(start:start+(length(polynomial)-1)) = ...
                mod(polynomial + checkdata(start:start+(length(polynomial)-1)), 2);        
        end
    end

    %Remove the checksum from the input data and send the actual data
    %to the output
    data_out = [data_in(1:end-(length(polynomial)-1))];
    
    %Convert from vector binary to matlab binary string and decimal
    binstr = strrep(num2str(checkdata(end-(length(polynomial)-1-1):end)),' ','');
    decstr = bin2dec(binstr);

    %Display the checksum value
    checksum_value = sprintf('%X',decstr);
    if sum(checkdata(end-(length(polynomial)-1-1):end))
        sprintf('CRC ERROR : The Checksum value is 0x%s',checksum_value)
        ERROR = 1;
    else
        sprintf('CRC CORRECT : The Checksum value is 0x%s',checksum_value)
        ERROR = 0;
    end

end