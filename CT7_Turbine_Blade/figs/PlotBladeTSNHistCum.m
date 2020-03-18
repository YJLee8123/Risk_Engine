% Plot cumulative histogram of TSN of blisk in operation.
%
% Revision history
% 121219 LDY Code was created.

clear; clc;

% Constant
EFHPerCyc = 1/1.7;    % Engine flight hour per cycle, [h/cyc]

% Data
data = csvread('../[1]data_preprocessing/ct7_tb_tsn_cyc.csv');
tsn = data(:, 1);           % Time since new, [cyc]
tsnTime = tsn*EFHPerCyc;    % [h]

% Edges
Bins = linspace(0, 10000, 40);    % [cyc]
BinsTime = linspace(0, 6000, 40);    % [h]

% Plot
histogram(tsn, Bins, 'Normalization', 'cdf');
%histogram(tsnTime, BinsTime, 'Normalization', 'cdf');

% Format
grid on
set(gca, 'FontSize', 14);
set(gca, 'FontWeight', 'bold');

xl = xlabel('TSN (cyc)');
%xl = xlabel('TSN (h)');
set(xl, 'FontSize', 15);
set(xl, 'FontWeight', 'bold');
yl = ylabel('Probability');
set(yl, 'FontSize', 15);
set(yl, 'FontWeight', 'bold');