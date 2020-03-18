% Weibull probability plot for 1st stage turbine blade in operation
%
% Revision history
% 121219 LDY Code was modified from 'ct7_turbine_blade_analysis/plotWblProbPaperTime.m'.
% 121219 LDY Code was modified for data in cycles.

clear; clc;

% Constant
EFHPerCyc = 1/1.7;    % Engine flight hour per cycle, [h/cyc]

% Parameters (JMP results)
alphaWbl = 7540;    % Location parameter
betaWbl = 4.80;     % Shape parameter

% Fractured blade POF (Minitab results)
cycFail = [ ...
    3486, 4932, 5050, 6612, 6792, ...
    7932, 7984, 7999, 8974, 8995];    % [cyc]
pof = [ ...
    6.73, 16.35, 25.96, 35.58, 45.19, ...
    54.81, 64.42, 74.04, 83.65, 93.27]/100;    % [%]

% Domain
X = linspace(1.5e3, 1e4, 10);

% Probability plot
loglog(X, X, '-', 'LineWidth', 2); hold on
loglog(cycFail, wblinv(pof, alphaWbl, betaWbl), 'ok', 'MarkerFaceColor', 'k');
hold off

% Format
grid on
axis([1.5e3, 1e4, wblinv([0.01, 0.99], alphaWbl, betaWbl)]);
set(gca, 'XTick', [1500, 2000, 3000, 4000, 5000, 6000, 8000, 10000]);
pLabel = [0.01, 0.02, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99];
set(gca, 'YTick', wblinv(pLabel, alphaWbl, betaWbl));
set(gca, 'YTickLabel', pLabel*100);
set(gca, 'FontSize', 14);
set(gca, 'FontWeight', 'bold');

xl = xlabel('TSN (cyc)');
set(xl, 'FontSize', 15);
set(xl, 'FontWeight', 'bold');
yl = ylabel('Probability (%)');
set(yl, 'FontSize', 15);
set(yl, 'FontWeight', 'bold');