clear all
 
% USAMPR = 2;
% 
SET_3DB_POINT = 1;
 
fsamp = 1;
% fp = (fsamp / 2) / USAMPR;
% fc = (fsamp / 2) / USAMPR;
% fs = fc + 0.01;
 
fc = 0.2;
fp = fc - 0.01;
fs = fc + 0.01;
ripple = 0.001; %ripple in dB
rejection = 60; %rejection in dB
 
omega_p=2*pi*(fp/fsamp);
omega_s=2*pi*(fs/fsamp);
omega_c=2*pi*(fc/fsamp);
 
eta = sqrt(power(10,ripple/10)-1);
A2 = sqrt(power(10,rejection/10)-1);
A2 = sqrt(power(10,3/10)-1);
 
c = 1 / tan(omega_p / 2);
 
pre_warped_omega_s = c*tan(omega_s/2);
 
M = log((A2 / eta) + sqrt(power(A2 / eta,2) - 1)) / ...
    log((pre_warped_omega_s) ...
    + sqrt(power(pre_warped_omega_s,2) - 1));
 
N = ceil(M);
 
if SET_3DB_POINT
    x=1/2
    omega_p = 2*atan(tan(omega_c / 2) ...
        / cosh((1 / N)*acosh( sqrt( (1 / x) - 1) / eta) ) ); 
    c = 1 / tan(omega_p / 2); 
end
 
p = [];
n = N;
gammav = power((1/eta) + sqrt(1+(1/power(eta, 2))), 1/N);
O1 = -(gammav - (1 / gammav)) / 2;
O2 = (gammav + (1 / gammav)) / 2;
while n
    sigma = O1*sin(((2*n - 1)*pi)/(2*N));
    omega = O2*cos(((2*n - 1)*pi)/(2*N));
    p = [p sigma+j*omega];
    n = n - 1;
end
 
bilin =  @(s,c) (1+s./c)./(1-s./c)
 
z = bilin(p,c);
 
a = [];
b = [];
n = N;
Z = length(z);
while Z
    if mod(Z, 2)
        a = [a 1 real( z(((Z+1)/2)) )];
        b = [b 1 1];
        z = [z(1:(((Z+1)/2)-1)) z((((Z+1)/2)+1):end) ];
        n = n - 1;
    else
        a = [a 1 real(z(1) + z(end)) real(-z(1)*z(end))];
        b = [b 1 2 1];
        z = z(2:end-1);
        n = n - 2;
    end
    Z = length(z);
end
 
if mod(N, 2)
    prod = (b(1)+b(2)) / (a(1)-a(2));
    start_index = 3;
else
    prod = (b(1)+b(2)+b(3)) / (a(1)-a(2)-a(3));
    start_index = 4;
end
 
for i = start_index:3:length(a)
    prod = prod * ((b(i)+b(i+1)+b(i+2)) / (a(i)-a(i+1)-a(i+2)));
end
 
if mod(N, 2)
    k = 1 / prod;
else
    k = (1 / sqrt(1 + power(eta, 2))) / prod;
end
 
if mod(N, 2)
    atot = [a(1) -a(2)];
    btot = [b(1) b(2)];
    start_index = 3;
else
    atot = [a(1) -a(2) -a(3)];
    btot = [b(1) b(2) b(3)];
    start_index = 4;
end
 
for i = start_index:3:length(a)
    atot = conv(atot, [a(i) -a(i+1) -a(i+2)]);
    btot = conv(btot, [b(i) b(i+1) b(i+2)]);
end
 
fvtool(k*btot,atot)

