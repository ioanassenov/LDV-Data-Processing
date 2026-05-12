% Clear
clear; clc; close all;

% initialize
daqreset;
d = daqlist("ni") %#ok<*NOPTS>
deviceinfo1 = d{1,"DeviceInfo"}
dq = daq("ni"); %init
dq.Rate = 100000; % specified rate

% add desired inputs
addinput(dq,'cDAQ9185-1C61526Mod1','ai0',"Voltage"); % Loopback input (read back input we put in mirror)
addinput(dq,'cDAQ9185-1C61526Mod1','ai1',"Voltage"); % Output voltage (from LDV)
addoutput(dq,'cDAQ9185-1C61526Mod2',"ao0","Voltage"); % Input voltage (into mirror)

% Create piecewise signal.
% Sweep down from higher frequency into the frequency we want to hold for
% testing. Downsweep helps mirror move and achieve higher displacements.
duration = 30; %seconds
fl = 400; % lowest freq (Hold at this frequency)
fh = 1200; % highest freq
amplitude = 25/6; % 1.25 = 50, 1.5 = 60, 1.75 = 70, 2 = 80
d = 0.5; % duty_cycle (for square wave)

rampupTime = 10; % Time in seconds that the downsweep lasts before hold
tRampup = linspace(0, rampupTime, dq.Rate*rampupTime);
tHold = linspace(rampupTime, duration, dq.Rate*(duration-rampupTime));
t = linspace(0,duration,dq.Rate*duration); % t = [tRampup, tHold]; or just total time

% Construct waveform
rampupSignal = linspace(fh, fl, length(tRampup));
holdSignal = linspace(fl, fl, length(tHold));
fullSignal = [rampupSignal holdSignal];
downsweep =  amplitude*sawtooth(2*pi*cumsum(fullSignal)/dq.Rate); % Sawtooth wave downsweep from high to low freq and hold low.
% downsweep = amplitude*chirp(t,ff,duration,fi,"linear"); % Sinusoidal wave (regular sweep, no hold)
% downsweep = duty_cycle(downsweep', d, amplitude); % Square wave

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
close all;

figure();
fTimeDown = linspace(fh,fl,length(t));
plot(fTimeDown, z_down);
title("Displacement vs Frequency (Downsweep)");
xlabel("Frequency [Hz]");
ylabel("Displacement [m]");


figure();
plot(t, z_down);
title("Displacement vs Time (Downsweep)");
xlabel("Time [s]"); ylabel("Displacement [m]");