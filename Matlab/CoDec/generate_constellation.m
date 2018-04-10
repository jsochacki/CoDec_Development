clear all
bits_in_int = 16;
max_int = ((2^(bits_in_int-1)) - 1); 
min_int = -(2^(bits_in_int-1));
%max_int = 10027;
max_uint = ((2^(bits_in_int)) - 1); 
min_uint = 0;

MODCOD = 3;
[Complex_Alphabet ...
      Binary_Alphabet ...
      Decimal_Alphabet ...
      BITS_PER_WORD] ...
          = dvbs2_Constellations(MODCOD);

i_values = real(Complex_Alphabet);
q_values = imag(Complex_Alphabet);

i_values = i_values ./ max(abs(i_values));
q_values = q_values ./ max(abs(q_values));

i_values = int32(i_values * max_int);
q_values = int32(q_values * max_int);

fid = fopen('./constellation.txt','w');
if (fid < 0)
   error('Unable to open constellation.txt');
end
for n = 1:1:length(i_values)
   line = sprintf('0x%x %d %d\n',n-1, i_values(n), q_values(n));
   fprintf(fid,line);
end
fclose(fid);
