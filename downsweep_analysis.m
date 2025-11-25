% Title: 
% Filename: downsweep_analysis.m
% Author: Ioan Assenov
%
% Description: Data processing script to analyze data collected from the
% LDV with a downsweep sawtooth wave input.

clear; clc; close all;

% Load data
data = load("Data/MEMS32_DownSweep_To_Fixed_Test_2.mat");

% Extract relevant fields from the loaded data
t = data.data.Time;
Vin = data.data.V_in;
Vldv = data.data.V_LDV;

% Useful properties from data:
T = seconds(0.00025);    % Period of input
offset = seconds(1e-5);  % offset from start of first period in graph
SStime = seconds(0.2424);% Time of first steady state peak of repsonse
T_sys = seconds(0.03321);% Period of system
f_sys = 1/0.03321;

% Plotting
startT = 4990; % Start input period to plot from (exclusive)
endT = 5010;   % Last input period to plot until (inclusive)
hold on;
yyaxis left;
plot(t, Vin, "LineWidth", 2);
yyaxis right;
plot(t, Vldv, "LineWidth", 2);
xlim([offset+startT*T, endT*T]);
% xlim([SStime+10*T_sys, 100*T_sys]);
% xlim([seconds(0.4), seconds(0.5)]);
legend("V_{in}", "V_{LDV}");