clear;
close all;

fs = 100000; % Sample rate of all collected data is 100e3
data = load("Data/MEMS32_AnalogFilterTest1.mat");
data = data.data(1:fs*20, :); % Pull table out of 1x1 struct
% Truncate data to first 20 seconds


%%
close all; 
fs = 100e3; % [Hz] Sample rate
gain = 0.125;
t = seconds(data.Time);
norm_V_LDV = data.V_LDV - mean(data.V_LDV);

% Define bandpass filter
GHPF = tf([180000 0],[1 2*pi*100]); % High Pass
GLPF = tf([0 1], [1 2*pi*30e3]);    % Low Pass

% Filter velocity
figure()
bode(GHPF*GLPF)
% velocity = norm_V_LDV;
velocity = lsim(GHPF*GLPF, norm_V_LDV, t);

% velocity = bandpass(norm_V_LDV,[100 30e3],fs); % The built-in bandpass is strange
velocity = velocity*gain;
% velocity = norm_V_LDV*gain;
time_step = 1e-5;
prev_x = 0;
x = zeros(1, length(velocity));

for i = 1:length(velocity)
    x(i) = velocity(i)*time_step + prev_x;
    prev_x = x(i);
end

figure;
hold on;
plot(data.Time, x, "LineWidth", 1.5);
ylim([-70e-6, 70e-6]);
ylabel('Displacement (m)');
yyaxis right;
plot(data.Time, data.V_in, "LineWidth", 1);
ylabel("Input Voltage [V]");
ylim([0, 3]);
title('Displacement vs Time');
xlabel('Time (sec)');
legend(["Displacement", "V_{in}"])
xlim([seconds(19), seconds(19.01)]);

%{
peaks = findpeaks(x);

figure;
histogram(peaks,10);
xlabel('Displacement (m)');
ylabel('Quantity');
%}