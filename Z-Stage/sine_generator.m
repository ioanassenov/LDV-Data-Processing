clc;

% Using NI 9222 (ID: "cDAQ9185-1C61526Mod1")
daqreset; % Reset daq if not already done
dq = daq("ni");
dqID = "cDAQ9185-1C61526Mod2"; % ID of analog output DAQ

fs = 100000; % Sampling freq
dq.Rate=fs;

% Define sine wave for signal
A = 25/6; % [V]
freq = 400; % [Hz]
b=0; % [V] Bias
t = linspace(0, 1/freq*200, fs/2); % The 200 coefficient is needed to get the correct period.
waveOutput = A.*sin(2.*pi.*freq.*t)' + b;

% Specify output pin
addoutput(dq, dqID, "ao0", "Voltage");

% Load the sine wave and start continuous output.
% To stop and reset, run `daqreset` in command window.
preload(dq,waveOutput);
start(dq, "repeatoutput"); 

% Print status messages
fprintf("Outputting continuous sine wave with frequency %i Hz, amplitude %.3f Volts\n", freq,A);
fprintf("Reset daq with `daqreset` to restart.\n");