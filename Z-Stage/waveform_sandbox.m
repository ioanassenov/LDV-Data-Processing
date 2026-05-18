% Clear
clear; clc;
% close all;

% ------------------------------ Bookmarks --------------------------------
% Clear nonlinear response between 2780-2860Hz with following parameters:
% Duration: 10, downsweep time: 8, Freq high: 3000, Freq low: 1590
% Using device #35
%
% Sustained high-displacement nonlinear response with following parameters:
% Duration: 15, downsweep time: 1.49, Freq high: 3000, Freq low: 2740
% Using device #35
%
% Sustained high-displacement linear response w/ params:
% Duration: 10, downsweep time: 0, Freq high: 3000, Freq low 1070
% Using device #35
% ------------------------------ Bookmarks --------------------------------

% Adjustable downsweep parameters
fl = 2740; % lowest freq (Hold at this frequency) symbol: f_l
fh = 3000; % highest freq symbol: f_h

% Define downsweep profile via sweeprate
% sweepRate = 25; % [Hz/s]
% downsweepTime = (fh-fl)/sweepRate;

% Define downsweep profile via duration
downsweepTime = 1.49; % [s] Time in seconds that the downsweep lasts before hold symbol: t_down
sweepRate = (fh-fl)/downsweepTime;

duration = 10; % [s]

% Create piecewise signal.
% Sweep down from higher frequency into the frequency we want to hold for
% testing. Downsweep helps mirror move and achieve higher displacements.
fs = 100000; % Sampling frequency (DAQ Rate)
amplitude = 25/6; % 1.25 = 50, 1.5 = 60, 1.75 = 70, 2 = 80
tDownsweep = linspace(0, downsweepTime, fs*downsweepTime);
tHold = linspace(downsweepTime, duration, fs*(duration-downsweepTime));
t = linspace(0,duration,fs*duration); % t = [tRampup, tHold]; or just total time

% Construct waveform
rampupSignal = linspace(fh, fl, length(tDownsweep));
holdSignal = linspace(fl, fl, length(tHold));
fullSignal = [rampupSignal holdSignal];
% downsweep = sin(2*pi*cumsum(fullSignal)/fs); % Sinus wave
% downsweep = duty_cycle(downsweep', 0.5, amplitude); % Square wave (sinus wave definition required).
downsweep =  amplitude*sawtooth(2*pi*cumsum(fullSignal)/fs, 1); % Sawtooth wave downsweep from high to low freq and hold low.

% initialize
daqreset;
d = daqlist("ni") %#ok<*NOPTS>
deviceinfo1 = d{1,"DeviceInfo"}
dq = daq("ni"); %init
dq.Rate = fs; % Daq rate

% add desired inputs
addinput(dq,'cDAQ9185-1C61526Mod1','ai0',"Voltage"); % Loopback input (read back input we put in mirror)
addinput(dq,'cDAQ9185-1C61526Mod1','ai1',"Voltage"); % Output voltage (from LDV)
addoutput(dq,'cDAQ9185-1C61526Mod2',"ao0","Voltage"); % Input voltage (into mirror)

% simultaneous acquiring and writing data
data2 = readwrite(dq, downsweep'); % IF SQUARE WAVE ADD AN '
data2 = renamevars(data2,["cDAQ9185-1C61526Mod1_ai0","cDAQ9185-1C61526Mod1_ai1"], ["V_in","V_LDV"]);

% Bandpass filter downsweep data
LDVgain = 125e-3;
fHPF = 100;
GHPF = tf([1/(2*pi*fHPF) 0], [1/(2*pi*fHPF) 1]);
fLPF = 10000;
GLPF = tf(2*pi*fLPF, [1 2*pi*fLPF]);
Gint = tf([1],[1 0]);
dzdtfilt = lsim(GHPF,LDVgain*data2.V_LDV,t);
z_down = lsim(Gint*GHPF*GLPF, dzdtfilt, t); 

% Plotting
% close all;
paramString = sprintf("Duration: %d, Downsweep time: %d, f_h: %d, f_l: %d", duration, downsweepTime, fl, fh); % Define parameter string to encode unique experiment parameters (for reproducibility)


figure();
subplot(2, 1, 1);
fTimeDown = linspace(fh,fl,length(t));
plot(fTimeDown, z_down);
title("Displacement vs Frequency (Downsweep)", paramString);
xlabel("Frequency [Hz]");
ylabel("Displacement [m]");

subplot(2, 1, 2);
plot(t, z_down);
xline(downsweepTime, '--k'); % Vertical line at downsweep end time.
title("Displacement vs Time (Downsweep)");
xlabel("Time [s]"); ylabel("Displacement [m]");


function outputArray = duty_cycle(array, d, a)
    for i = 1:length(array)
        if array(i) > cos(pi*d)
            outputArray(i) = a;
        else
            outputArray(i) = -1*a;
        end
    end
end