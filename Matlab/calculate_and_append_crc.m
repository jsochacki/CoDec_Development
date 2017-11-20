function [data_out CRC_value] = calculate_and_append_crc(data_in, polynomial)

%This has been verified as correct and functional when compared to the
%DVBS2 manual and the online checksum calculator @ http://crccalc.com/

    if ischar(polynomial)
        polynomial = get_crc_polynomial(polynomial);
    end

    %Zero padd so you can capture the CRC remainder (result)
    crcdata = [data_in zeros(1,length(polynomial) - 1)];

    start = 1;
    while start <= (length(crcdata) - (length(polynomial) - 1))
        if crcdata(start) ~= 1
            start = start + 1;
        else
            crcdata(start:start+(length(polynomial)-1)) = ...
                mod(polynomial + crcdata(start:start+(length(polynomial)-1)), 2);        
        end
    end

    %Append CRC to input data and send to output
    data_out = [data_in crcdata(end-(length(polynomial)-1-1):end)];
    
    %Convert from vector binary to matlab binary string and decimal
    binstr = strrep(num2str(crcdata(end-(length(polynomial)-1-1):end)),' ','');
    decstr = bin2dec(binstr);

    %Display the crc value
    CRC_value = sprintf('%X',decstr);
    sprintf('The CRC value is 0x%s',CRC_value)
end