% Weibull probability plot for 1st stage turbine blade in operation
%
% Revision history
% 121219 LDY Code was modified from 'ct7_turbine_blade_analysis/plotWblProbPaperTime.m'.
% 121219 LDY Code was modified for data in cycles.

clear; clc;

% Constant
EFHPerCyc = 1/1.7;        % Engine flight hour per cycle, [h/cyc]

% Parameters (JMP results)
alpha95low = 13786.0;    % Lower 95%
alpha95up = 24134.4;     % Upper 95%
alpha = 18240.6;         % KAF data only
alphaGE = 64435.7;       % Including GE data
beta = 5;

% Fractured blade POF (Minitab results)
cycFail = 5829;    % [cyc]
pof = 0.00201349/100;

% Domain
X = linspace(5e3, 5e4, 10);

% Probability plot
loglog(X, X, '-', 'LineWidth', 2); hold on
loglog(cycFail, wblinv(pof, alphaGE, beta), 'ok', 'MarkerFaceColor', 'k');
hold off

% Format
grid on
axis([5e3, 5e4, wblinv([0.00001, 0.95], alphaGE, beta)]);
set(gca, 'XTick', [5000, 10000, 2e4, 3e4, 5e4]);
pLabel = [0.00001, 0.0001, 0.001, 0.005, 0.01, 0.02, 0.05, 0.2, 0.5, 0.8, 0.95];
set(gca, 'YTick', wblinv(pLabel, alphaGE, beta));
set(gca, 'YTickLabel', pLabel*100);
set(gca, 'FontSize', 14);
set(gca, 'FontWeight', 'bold');

xl = xlabel('TSN (cyc)');
set(xl, 'FontSize', 15);
set(xl, 'FontWeight', 'bold');
yl = ylabel('Probability (%)');
set(yl, 'FontSize', 15);
set(yl, 'FontWeight', 'bold');