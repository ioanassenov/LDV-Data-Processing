% Clear
clear; clc; close all;

% initialize
daqreset;
d = daqlist("ni") %#ok<*NOPTS>
deviceinfo1 = d{1,"DeviceInfo"}
dq = daq("ni"); %init
dq.Rate = 100000; % specified rate

% add desired inputs
% change when using different daq
addinput(dq,'cDAQ9185-1C61526Mod1','ai0',"Voltage");
addinput(dq,'cDAQ9185-1C61526Mod1','ai1',"Voltage");
%addinput(dq,'PCIE6374','ai2',"Voltage");
%addinput(dq,'PCIE6374','ai3',"Voltage");
addoutput(dq,'cDAQ9185-1C61526Mod2',"ao0","Voltage");

% create signal
duration = 10; %seconds
fi = 800; % intital freq
ff = 1200; % final freq
amplitude = 25/6; % 1.25 = 50, 1.5 = 60, 1.75 = 70, 2 = 80
d = 0.5; % duty_cycle

t = linspace(0,duration,dq.Rate*duration);

upsweep = amplitude*chirp(t,fi,duration,ff);
% upsweep = duty_cycle(upsweep',d, amplitude); % Convert to square wave

% simultaneous acquiring and writing data
data1 = readwrite(dq, upsweep'); % IF SQUARE WAVE ADD AN '
data1 = renamevars(data1,["cDAQ9185-1C61526Mod1_ai0","cDAQ9185-1C61526Mod1_ai1"], ["V_in","V_LDV"]);

downsweep = amplitude*chirp(t,ff,duration,fi,"linear");
% downsweep = duty_cycle(downsweep', d, amplitude); % Convert to square wave
data2 = readwrite(dq, downsweep'); % IF SQUARE WAVE ADD AN '
data2 = renamevars(data2,["cDAQ9185-1C61526Mod1_ai0","cDAQ9185-1C61526Mod1_ai1"], ["V_in","V_LDV"]);


% Bandpass filter upsweep data
% LDVgain = 125e-3;
% fHPF = 100;
% GHPF = tf([1/(2*pi*fHPF) 0], [1/(2*pi*fHPF) 1]);
% fLPF = 10000;
% GLPF = tf(2*pi*fLPF, [1 2*pi*fLPF]);
% Gint = tf([1],[1 0]);
% dzdtfilt = lsim(GHPF,LDVgain*data1.V_LDV,t);
% z_up = lsim(Gint*GHPF*GLPF, dzdtfilt, t); 

% Bandpass filter downsweep data
LDVgain = 125e-3;
fHPF = 100;
GHPF = tf([1/(2*pi*fHPF) 0], [1/(2*pi*fHPF) 1]);
fLPF = 10000;
GLPF = tf(2*pi*fLPF, [1 2*pi*fLPF]);
Gint = tf([1],[1 0]);
dzdtfilt = lsim(GHPF,LDVgain*data2.V_LDV,t);
z_down = lsim(Gint*GHPF*GLPF, dzdtfilt, t); 

%% Plotting
close all;

% figure();
% fTimeUp = linspace(fi,ff,length(t));
% plot(fTimeUp, z_up);
% title("Displacement vs Frequency (Upsweep)");
% xlabel("Frequency [Hz]");
% ylabel("Displacement [m]");

figure();
fTimeDown = linspace(ff,fi,length(t));
plot(fTimeDown, z_down);
title("Displacement vs Frequency (Downsweep)");
xlabel("Frequency [Hz]");
ylabel("Displacement [m]");

% figure;
% plot(data1.Time, data1.V_in);
% title("Frequency Upsweep Input");
% xlabel("Time (s)");
% ylabel("Voltage (V)");
% grid on;
% 
% figure;
% plot(data2.Time, data2.V_in);
% title("Frequency Downsweep");
% xlabel("Time (s)");
% ylabel("Voltage (V)");
% grid on;
% 
% figure;
% plot(data1.Time, data1.V_LDV);
% title("Frequency Upsweep LDV");
% xlabel("Time (s)");
% ylabel("Voltage LDV (V)");
% grid on;
% 
% figure(4);
% plot(data2.Time, data2.V_LDV);
% title("Frequency Downsweep LDV");
% xlabel("Time (s)");
% ylabel("Voltage LDV (V)");
% grid on;
% 
% % -------------Timetable conversion code-------------- %
% % Convert timetable to table for easier manipulation
% upSweepData =  timetable2table(data1);
% downSweepData =  timetable2table(data2);
% 
% % Convert first column variables from duration to numeric
% upSweepData = convertvars(upSweepData, "Time", "seconds");
% downSweepData = convertvars(downSweepData, "Time", "seconds");

% Convert table into an array for easier indexing (optional)
%arrayUpSweep = table2array(upSweepData);
%arrayDownSweep = table2array(downSweepData);

% ------------------------------------------------

%writetimetable(data1,'Up_Sweep.csv');
%d ritetimetable(data2,'Down_Sweep.csv');

function outputArray = duty_cycle(array, d, a)
    for i = 1:length(array)
        if array(i) > cos(pi*d)
            outputArray(i) = a;
        else
            outputArray(i) = -1*a;
        end
    end
end



% Dvice 24 most likely spot: near 2.214 kHz (main motion at 370 Hz)
% or near 740 Hz (main motion at 370 Hz)



% clearvars t d amplitude upsweep downsweep;
% clearvars fi ff duration dq deviceinfo1 data2 data1;

%windowseg = [];
%[pxx1,f1] = pwelch(data1.V_in,windowseg,[],[],dq.Rate,"power");
%[pxx2,f2] = pwelch(data1.("Current_mv/ua"),windowseg,[],[],dq.Rate,"power");
%[pxx3,f3] = pwelch(data1.Impedance,windowseg,[],[],dq.Rate,"power");
% 
%hold on
%figure()
%plot(f1,pow2db(pxx1))
%plot(f2,pow2db(pxx2))
%plot(f3,pow2db(pxx3))
% [pk1,loc1] = findpeaks(pxx1,f1,MinPeakDistance=10);
% [pk2,loc2] = findpeaks(pxx2,f2,MinPeakDistance=10);
% [pk3,loc3] = findpeaks(pxx3,f3,MinPeakDistance=10);
% plot(loc1,pow2db(pk1))
% plot(loc2,pow2db(pk2))
% plot(loc3,pow2db(pk3))
% legend(["V in","Current mV/uA","Impedance"],"Location","best")
% xlabel('Frequency (Hz)')
% ylabel('Power (dB)')
% hold off
daqreset;
fprintf("Program completed!");
