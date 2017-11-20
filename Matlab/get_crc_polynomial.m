function polynomial = get_crc_polynomial(CRC_CODE)
    switch upper(CRC_CODE)
        case 'DVB-S2-CRC8'
            %%%%%
            % This is only used for packetized streams
            % the resultant CRC is to be placed in SYNC
            % field of the packet header.
            %
            % [X8,X7,X6,0,X4,0,X2,0,1]
            % polynomial = [1, 1, 1, 0, 1, 0, 1, 0, 1];
            % Hardcoded if you like or generate below
            %%%%%
            sub_polynomials = {};
            sub_polynomials{1} = [1 1 1 1 0 1];
            sub_polynomials{2} = [1 1 1];
            sub_polynomials{3} = [1 1];
            polynomial = generate_polynomial(sub_polynomials);
        case {'MPEG-2','FIPS','GZIP'}
            %%%%%
            % This is only used for idirect modems
            %
            % I only Hardcode as I don't know the sub polynomials
            %%%%%
            polynomial = [1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0,...
                          1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];
        case 'DVB-S2-BCH-NORMAL-T12'
            %%%%%
            % This generates the BCH polynomial for the normal size
            % FECFRAME for SVB-S2
            %
            % Generated Only from Table 6A DVBS2
            % Only applicable to the following code rates:
            % 1/4 1/3 2/5 1/2 3/5 3/4 4/5
            %%%%%
            sub_polynomials = {};
            %                    16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
            sub_polynomials{1} = [1  0  0  0  0  0  0 0 0 0 0 1 0 1 1 0 1];
            sub_polynomials{2} = [1  0  0  0  0  0  0 0 1 0 1 1 1 0 0 1 1];
            sub_polynomials{3} = [1  0  0  0  0  1  1 1 1 1 0 1 1 1 1 0 1];
            sub_polynomials{4} = [1  0  1  0  1  1  0 1 0 0 1 0 1 0 1 0 1];
            sub_polynomials{5} = [1  0  0  0  1  1  1 1 1 0 0 1 0 1 1 1 1];
            sub_polynomials{6} = [1  1  1  1  1  0  1 1 1 1 0 1 1 0 1 0 1];
            sub_polynomials{7} = [1  1  0  1  0  1  1 1 1 0 1 1 0 0 1 0 1];
            sub_polynomials{8} = [1  0  1  1  1  0  0 1 1 0 1 1 0 0 1 1 1];
            sub_polynomials{9} = [1  0  0  0  0  1  1 1 0 1 0 1 0 0 0 0 1];
            sub_polynomials{10}= [1  0  1  1  1  0  1 0 1 1 0 1 0 0 1 1 1];
            sub_polynomials{11}= [1  0  0  1  1  1  0 1 0 0 0 1 0 1 1 0 1];
            sub_polynomials{12}= [1  0  0  0  1  1  0 1 0 1 1 1 0 0 0 1 1];
            polynomial = generate_polynomial(sub_polynomials);
        case 'DVB-S2-BCH-NORMAL-T10'
            %%%%%
            % This generates the BCH polynomial for the normal size
            % FECFRAME for SVB-S2
            %
            % Generated Only from Table 6A DVBS2
            % Only applicable to the following code rates:
            % 2/3 5/6
            %%%%%
            sub_polynomials = {};
            %                    16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
            sub_polynomials{1} = [1  0  0  0  0  0  0 0 0 0 0 1 0 1 1 0 1];
            sub_polynomials{2} = [1  0  0  0  0  0  0 0 1 0 1 1 1 0 0 1 1];
            sub_polynomials{3} = [1  0  0  0  0  1  1 1 1 1 0 1 1 1 1 0 1];
            sub_polynomials{4} = [1  0  1  0  1  1  0 1 0 0 1 0 1 0 1 0 1];
            sub_polynomials{5} = [1  0  0  0  1  1  1 1 1 0 0 1 0 1 1 1 1];
            sub_polynomials{6} = [1  1  1  1  1  0  1 1 1 1 0 1 1 0 1 0 1];
            sub_polynomials{7} = [1  1  0  1  0  1  1 1 1 0 1 1 0 0 1 0 1];
            sub_polynomials{8} = [1  0  1  1  1  0  0 1 1 0 1 1 0 0 1 1 1];
            sub_polynomials{9} = [1  0  0  0  0  1  1 1 0 1 0 1 0 0 0 0 1];
            sub_polynomials{10}= [1  0  1  1  1  0  1 0 1 1 0 1 0 0 1 1 1];
            polynomial = generate_polynomial(sub_polynomials);
        case 'DVB-S2-BCH-NORMAL-T8'
            %%%%%
            % This generates the BCH polynomial for the normal size
            % FECFRAME for SVB-S2
            %
            % Generated Only from Table 6A DVBS2
            % Only applicable to the following code rates:
            % 8/9 9/10
            %%%%%
            sub_polynomials = {};
            %                    16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
            sub_polynomials{1} = [1  0  0  0  0  0  0 0 0 0 0 1 0 1 1 0 1];
            sub_polynomials{2} = [1  0  0  0  0  0  0 0 1 0 1 1 1 0 0 1 1];
            sub_polynomials{3} = [1  0  0  0  0  1  1 1 1 1 0 1 1 1 1 0 1];
            sub_polynomials{4} = [1  0  1  0  1  1  0 1 0 0 1 0 1 0 1 0 1];
            sub_polynomials{5} = [1  0  0  0  1  1  1 1 1 0 0 1 0 1 1 1 1];
            sub_polynomials{6} = [1  1  1  1  1  0  1 1 1 1 0 1 1 0 1 0 1];
            sub_polynomials{7} = [1  1  0  1  0  1  1 1 1 0 1 1 0 0 1 0 1];
            sub_polynomials{8} = [1  0  1  1  1  0  0 1 1 0 1 1 0 0 1 1 1];
            polynomial = generate_polynomial(sub_polynomials);
        otherwise
            sprintf(['ERROR: The type of CRC being requested ',...
                    'is not a part of this program\n',...
                    'Please manually enter the polynomial vector ',...
                    'when using this function. \n'])
    end
end