clear; close all;

fs = 100000; % Sample rate of all collected data is 100e3
data = load("Data/MEMS32_AnalogFilterTest1.mat");
data = data.data(1:fs*20, :); % Pull table out of 1x1 struct and truncate to first 20 seconds
% NOTE: Steady state periodic response is reached after about 0.5 seconds.

%%
close all; 

% PARAMETERS
% Define boundaries for the x axis and apply truncation. This is done to
% improve performance of MATLAB graph with the huge dataset.
% To see the full picture, set minTime = 0 and maxTime = 20;
TRUNC_TIME_MIN = 6; % [s]
TRUNC_TIME_MAX = 6.1; % [s]
X_AXIS_MIN     = TRUNC_TIME_MIN;
X_AXIS_MAX     = TRUNC_TIME_MAX;
% X_AXIS_MIN     = 5.01; % [s]
% X_AXIS_MAX     = 5.1; % [s]

% c = 0.9999969708174821; 
% d = 1.000037630804575; 
% phi = 3319.720955485615;
RUN_FIT_SINE = true;
LEARNING_RATE = 0.2;
ITERATIONS = 5e3;

% ========== DATA TRUNCATION ==========

% Store data in convenient variables:
time = data.Time;
t = seconds(time);
vin = data.V_in;
vldv = data.V_LDV;
x = calc_displacement(data); % Convert V_LDV to displacement

% Truncate the data based on the parameters set at the top of the section
trunc_mask = time >= seconds(TRUNC_TIME_MIN) & time <= seconds(TRUNC_TIME_MAX); % Logical mask matrix for truncation
time = time(trunc_mask);
t = t(trunc_mask);
x = x(trunc_mask);
vin = vin(trunc_mask);

% Find peaks of displacement (x) and input voltage (V_in)
[peaks_x, locs_x] = findpeaks(x);
[peaks_vin, locs_vin] = findpeaks(vin');


% Wave parameters of displacement
period_x = seconds(time(locs_x(end)) - time(locs_x(end-1))); % Seconds (integer type)
amplitude_x = (max(x)-min(x))/2; % [m]
% Wave parameters of input voltage
period_vin = seconds(time(locs_vin(end)) - time(locs_vin(end-1))); % Period of V_in in seconds (integer type)
amplitude_vin = (max(vin)-min(vin))/2; % [V]

% ========== END DATA TRUNCATION ==========

% ========== SIGNAL APPROXIMATION ==========
% Estimate guess signal based on the information from the input.
% Ideally, all the terms in the guessSignal should be functions of V_in.
% guess_period = (period_vin*2); % Displacement period is twice the V_in period.
guess_period = (1/528.35); % Displacement period is twice the V_in period.
guess_phase = 2*pi/guess_period; % Phase shift is based on the offset of V_in from x.
guess_amplitude = amplitude_x; % TODO (make a function of v_in)

% Use gradient descent to find correction factors
if RUN_FIT_SINE
    fprintf("Running fit_sine()\n")
    [c,d,phi] = fit_sine(t, x, guess_amplitude, guess_period, guess_phase, LEARNING_RATE, ITERATIONS);
    fprintf("fit_sine() finished! \nc = %.16g; \nd = %.16g; \nphi = %.16g;\n\n", c, d, phi);
end

guessSignal = c*guess_amplitude * sin(2*pi/(d*guess_period) * t + phi);

% ========== END SIGNAL APPROXIMATION ==========


% ========== PLOTTING ==========

% Plot the input voltage (V_in) and displacement (x)
% on the same graph to compare the signals.
fig = figure(Theme="Light");
hold on;

% Left axis: displacement with peaks and approximated signal
yyaxis left
plot(time, x, "LineWidth", 1.5, "Color", "blue");
plot(t, guessSignal, "LineWidth", 1.5, "Color", "#109010", "LineStyle", "-");
scatter(time(locs_x), peaks_x, 15, "blue", "filled");
ylim([min(x)*1.1, max(x)*1.1]);
ylabel('Displacement (m)');
xlim([seconds(X_AXIS_MIN), seconds(X_AXIS_MAX)]);

% Right axis: input voltage signal with peaks
% yyaxis right;
% plot(time, vin, "LineWidth", 1, "Color", "red");
% ylabel("Input Voltage [V]");
% ylim([0, 3]);
% title('Displacement vs Time');
% xlabel('Time (sec)');
% % Plot peaks
% scatter(time(locs_vin), peaks_vin, 15, "red", "filled");

% Allow zoom only along the x axis (keep y axis fixed when scrolling).
% Allow scrubbing on the graph to see values of points.
ax = gca;
ax.Interactions = [zoomInteraction(Dimensions='x'), dataTipInteraction];


% legend(["Displacement", "Displacement peaks", "V_{in}", "V_{in} Peaks"], "Location", "bestoutside")

% ========== END PLOTTING ==========