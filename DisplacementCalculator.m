clear;
close all;

% fullSignal = load("fullInputSignal.mat");
% fullSignal = fullSignal.fullSignal;

data = load("Data/10minLDVrawdata.mat");
data = data.data; % Pull table out of 1x1 struct

%%
fs = 100000; % Sample rate of all collected data is 100e3
gain = 0.125;
norm_V_LDV = data.V_LDV - mean(data.V_LDV);
velocity = bandpass(norm_V_LDV,[100 30e3],fs);
velocity = velocity*gain;
%velocity = norm_V_LDV*gain;
time_step = 1e-5;
prev_x = 0;
x = zeros(1, length(velocity));

for i = 1:length(velocity)
    x(i) = velocity(i)*time_step + prev_x;
    prev_x = x(i);
end

figure;
plot(data.Time, x);
title('60 V Displacement vs Time');
ylabel('Displacement (m)');
xlabel('Time (sec)');

%{
peaks = findpeaks(x);

figure;
histogram(peaks,10);
xlabel('Displacement (m)');
ylabel('Quantity');
%}
clearvars prev_x fs time_step i gain;
