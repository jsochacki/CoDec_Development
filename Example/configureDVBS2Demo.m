%configureDVBS2Demo Create and configure System objects for the DVB-S.2
%MATLAB(R) example commDVBS2WithLDPC. 

% Copyright 2010-2011 The MathWorks, Inc.

%% Simulation Parameters
% Set simulation parameter and constants

% Set up system parameters and display the parameter structure
maxNumLDPCIterations = 50;
dvb = getParamsDVBS2Demo(subsystemType, EsNodB, maxNumLDPCIterations);

%% Simulation Objects
% Create System objects to simulate the DVB-S.2 system, such as the BCH
% encoder and PSK modulator.

createSimObjDVBS2Demo

%% Performance Measurements
% Create objects to measure the performance of the DVB-S.2 system, such as
% packet error rate (PER) and scatter plot.

%% 
% *Error Rate Calculators*
%
% Create error rate calculator System objects to obtain end-to-end packet
% error rate, LDPC decoder error rate, and demodulator output bit error
% rates of the system. 

hPER     = comm.ErrorRate;
hBERLDPC = comm.ErrorRate;
hBERMod  = comm.ErrorRate;

%%
% *Scatter Plot*
%
% Create a scatter plot to view the received constellation.

% Get the constellation
cacheBitInput = hMod.BitInput;
hMod.BitInput = false;
constellation = step(hMod, (0:hMod.ModulationOrder-1)');
release(hMod); hMod.BitInput = cacheBitInput;

% Initialize scatter plot
hRxConst = comm.ConstellationDiagram(...
    'SamplesPerSymbol',       1, ...
    'ReferenceConstellation', constellation, ...
    'XLimits',                [-3.5 3.5], ...
    'YLimits',                [-3.5 3.5], ...
    'Position',               [50 630 560 420]);

%%
% *SNR Measurement*
%
% Create variance and mean estimators to measure received signal SNR.

hVar = dsp.Variance;
hMean = dsp.Mean('RunningMean', true);
