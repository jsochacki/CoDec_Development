clear all

%%% THis script is the first and does the IIR Ideal despreading vs sochacki
%%% method comparison for a single short repeating pn code

PLOT=0;

USAMPR = 2;

%%% Filter information
a1 = [1, -0.0183, 0.8665];
a2 = [1, -0.1458, 0.6341];
a3 = [1, -0.3545, 0.4290];
a4 = [1, -0.5802, 0.2583];
a5 = [1, -0.7321, 0.1558];

b1 = [1 2 1]; % = b2 = b3 = b4 = b5

sos = [b1, a1; b1, a2; b1, a3; b1, a4; b1, a5];

k = 8.2924e-4;

%%% Alphabet Information
complex_mapping = exp(1j*([0,3,1,2].'*pi/2+pi/4)).';

Prefix = randsrc(1, 3 * size(sos,1),complex_mapping,3);

%%% Transmit Information
PN_Length = 512;
NSYMBOLS=32;

%%% Sequence Generation
c = randsrc(1,PN_Length,complex_mapping,123);
s = randsrc(1,NSYMBOLS,complex_mapping,233);

%%% Zero Order Holder
% x = repelem(s,length(c));

%%% Transmit Spreading
% cx = [];
% n = 0;
% while (n < length(x))
%     cx(n + 1) = x(n + 1) * c(mod(n, length(c)) + 1);
%     n = n + 1;
% end
cx = [];
n = 0;
while (n < length(s))
    cx = [cx (s(n + 1) * c)];
    n = n + 1;
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(cx,'bo')
end

% Transmit Filtering
cxup=upsample(cx,USAMPR);

% h = firrcos(512,0.5,.15,2,'rolloff','sqrt');

kk = power(k,1/5);
sout = [Prefix cxup Prefix];
for i = 1:1:size(sos, 1)
    sout = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),sout);
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(sout,'bo')
    plot(20*log10(abs(fftshift(fft(sout,length(sout))))))
end

%Normalize
sout=sout./max(abs(sout));

% Receive Filtering
bbdata_rx = fliplr(sout);
for i = 1:1:size(sos, 1)
    bbdata_rx = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),bbdata_rx);
end
bbdata_rx = fliplr(bbdata_rx);

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(bbdata_rx,'bo')
    plot(20*log10(abs(fftshift(fft(bbdata_rx,length(bbdata_rx))))))
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    n=((32*512)/2) + 1
    plot(downsample(bbdata_rx(1+n:end-n),2), 'bo')
    plot(downsample(bbdata_rx(1+(length(Prefix)):end),2), 'bo')
end

ind = 0;
r = 0;
hold off
plot((s))
hold on
while sum(abs(s-r)) > 0.05
f = downsample(bbdata_rx(1+ind:end-ind), USAMPR);

n = 0;
r = [];
while (n < length(s))
    r = [r (f(((n * length(c)) + 1):((n + 1) * length(c))) * c')];
    n = n + 1;
end
r = r / length(c);
r = r ./ max(abs(r));
ind = ind + 1;
plot((r))
sum(abs(s-r))
ind
end

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    plot(r,'bo')
end

%%% Calculate EsNo
EsNo_dB=[]; PERROR_Vector=[]; PREF_Vector=[];

VERROR=[];
VERROR=r-s;
PERROR_Vector=VERROR.*VERROR'.';
PREF_Vector=s.*s'.';

RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);

%%% Calculate EVM
EVM_dB=[];
EVM_dB=10*log10(RMS_PERROR/RMS_PREF);

% g = c'.'; %Mathematically correct but has different ind value than other way
% for i = 1:1:size(sos, 1)
%     g = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),g);
% end
% 
% ind = 0;
% r2 = 0;
% hold off
% plot((s))
% hold on
% while sum(abs(s-r2)) > 1
% f2 = downsample(sout(1+ind:end-ind), USAMPR);
% 
% n = 0;
% r2 = [];
% while (n < length(s))
%     r2 = [r2 (f2(((n * length(g)) + 1):((n + 1) * length(g))) * g.')];
%     n = n + 1;
% end
% r2 = r2 / length(g);
% r2 = r2 ./ max(abs(r2));
% ind = ind + 1;
% plot((r2))
% sum(abs(s-r2))
% ind
% end
% 
% % PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if PLOT
%     plot(r,'bo')
%     hold on
%     plot(r2,'ro')
% end
% 
% %%% Calculate EsNo
% EsNo_dB=[]; PERROR_Vector=[]; PREF_Vector=[];
% 
% VERROR=[];
% VERROR=r2-s;
% PERROR_Vector=VERROR.*VERROR'.';
% PREF_Vector=s.*s'.';
% 
% RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
% RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
% EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);
% 
% %%% Calculate EVM
% EVM_dB=[];
% EVM_dB=10*log10(RMS_PERROR/RMS_PREF);


g = upsample(c'.', USAMPR); %Mathematically correct but has different ind value than other way
for i = 1:1:size(sos, 1)
    g = filter(kk*sos(i, 1:1:3),sos(i, 4:1:6),g);
end

ind = 0;
r2 = 0;
hold off
plot((s))
hold on
while sum(abs(s-r2)) > 1
f2 = sout(1+ind:end-ind);

n = 0;
r2 = [];
while (n < length(s))
    r2 = [r2 (f2(((n * length(g)) + 1):((n + 1) * length(g))) * g.')];
    n = n + 1;
end
r2 = r2 / length(g);
r2 = r2 ./ max(abs(r2));
ind = ind + 1;
plot((r2))
sum(abs(s-r2))
ind
end
%%% Note the you don't need to actually downsample as your correlation
%%% compresses the sequence to a single value

% PLOT CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    hold off
    plot((s))
    hold on
    plot(r,'bo')
    hold on
    plot(r2,'ro')
end

%%% Calculate EsNo
EsNo_dB=[]; PERROR_Vector=[]; PREF_Vector=[];

VERROR=[];
VERROR=r2-s;
PERROR_Vector=VERROR.*VERROR'.';
PREF_Vector=s.*s'.';

RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);

%%% Calculate EVM
EVM_dB=[];
EVM_dB=10*log10(RMS_PERROR/RMS_PREF);