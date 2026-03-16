% Filename: estimate_ff.m
% Title: Estimate fundamental frequency
% Author: Ioan Assenov
% Date: 2026-03-13
% Desc: This is a function that takes a set of LDV data to calculate what
% the fundamental frequency of the displacement is at steady state for a
% given sawtooth input voltage.

function fund_freq = estimate_ff(data, sampling_frequency)
    % Store data in convenient variables:
    fs = sampling_frequency;
    vin = data.V_in;
    L = length(vin);
    
    Y = fft(vin);
    Y = abs(fftshift(Y));
    Y = Y/max(Y); % Normalize to max peak
    
    [~, locs] = findpeaks(Y, "MinPeakDistance", 10, "MinPeakProminence", 0.001, "SortStr","descend","NPeaks",30);
    
    freqaxis = fs/L*(-L/2:L/2-1);
    
    peak_freqs = freqaxis(locs); % Extract peak frequencies
    peak_freqs = peak_freqs(peak_freqs>0); % Select only positive half
    vin_fund_freq = min(peak_freqs); % Fundamental freq vin is the lowest
    fund_freq = vin_fund_freq/2; % Fundamental freq of disp is half vin ff
end