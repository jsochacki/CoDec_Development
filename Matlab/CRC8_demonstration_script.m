clear all
data = randsrc(1,128,[1 0]);

CRC = [];
[data_out CRC] = calculate_and_append_crc(data, 'DVB-S2-CRC8');

%Add Error
% data_out(100) = ~data_out(100)
% data_out(10) = ~data_out(10)

[data_final ERROR checksum_value] = check_crc(data_out, 'DVB-S2-CRC8');

if ERROR
    error_count = sum(mod(data + data_final, 2));
    sprintf('There were a total of %d bit errors.', error_count)
end