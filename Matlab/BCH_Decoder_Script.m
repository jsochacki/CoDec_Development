clear all
data = [1 1 0 1 1];

CRC = [];
[data_out CRC] = calculate_and_append_crc(data,[1 0 1 0 0 1 1 0 1 1 1]);

%Add Error
% data_out(100) = ~data_out(100)
% data_out(10) = ~data_out(10)

[data_final ERROR checksum_value] = check_crc(data_out,[1 0 1 0 0 1 1 0 1 1 1]);

if ERROR
    error_count = sum(mod(data + data_final, 2));
    sprintf('There were a total of %d bit errors.', error_count)
end