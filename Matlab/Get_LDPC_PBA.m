function [PBA_vector] = Get_LDPC_PBA(code_rate, coded_block_size)
    switch coded_block_size
        case 16200
            switch code_rate
                case '1/4'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_14_16.dat','r');
                case '1/3'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_13_16.dat','r');
                case '2/5'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_25_16.dat','r');
                case '1/2'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_12_16.dat','r');
                case '3/5'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_35_16.dat','r');
                case '2/3'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_23_16.dat','r');
                case '3/4'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_34_16.dat','r');
                case '4/5'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_45_16.dat','r');
                case '5/6'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_56_16.dat','r');
                case '8/9'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_89_16.dat','r');
                case '9/10'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_910_16.dat','r');
                otherwise
                    fid = -1; error = 'No such code rate in DVBS2';
            end
        case 64800
            switch code_rate
                case '1/4'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_14_64.dat','r');
                case '1/3'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_13_64.dat','r');
                case '2/5'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_25_64.dat','r');
                case '1/2'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_12_64.dat','r');
                case '3/5'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_35_64.dat','r');
                case '2/3'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_23_64.dat','r');
                case '3/4'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_34_64.dat','r');
                case '4/5'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_45_64.dat','r');
                case '5/6'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_56_64.dat','r');
                case '8/9'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_89_64.dat','r');
                case '9/10'
                    [fid, error] = fopen('LDPC_PBA_Address_Tables\DVB_910_64.dat','r');
                otherwise
                    fid = -1; error = 'No such code rate in DVBS2';
            end
        otherwise
            fid = -1; error = 'No such coded block size in DVBS2';
    end
    PBA_vector = fscanf(fid, '%d');
    fclose(fid);
    if isempty(error)
        sprintf('Success: Parity Bit Address Table Read Successfully')
    else
        sprintf('Failure: %s',error)
    end
end