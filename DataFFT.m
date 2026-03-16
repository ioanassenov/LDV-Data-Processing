clear; close all;

fs = 100000; % Sample rate of all collected data is 100e3
data = load("Data/MEMS32_AnalogFilterTest1.mat");
data = data.data(1:fs*20, :); % Pull table out of 1x1 struct and truncate to first 20 seconds
% NOTE: Steady state periodic response is reached after about 0.5 seconds.

% Store data in convenient variables:
time = data.Time;
vin = data.V_in;
vldv = data.V_LDV;
x = calc_displacement(data);
L = length(time);

Y = fft(vin);
Y = abs(fftshift(Y));
Y = Y/max(Y); % Normalize to max peak

[peaks, locs] = findpeaks(Y, "MinPeakDistance", 10, "MinPeakProminence", 0.001, "SortStr","descend","NPeaks",30);

freqaxis = fs/L*(-L/2:L/2-1);

peak_freqs = freqaxis(locs);
peak_freqs = peak_freqs(peak_freqs>0);
vin_fund_freq = min(peak_freqs);
x_fund_freq = vin_fund_freq/2;

semilogy(freqaxis, Y);
hold on;
title(sprintf('Fundamental Frequency: %.2f Hz', fund_freq));
scatter(freqaxis(locs), peaks, "filled");
xlabel("Frequency [Hz]");
xlim([-5e3, 5e3]);