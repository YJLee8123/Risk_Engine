% Weibull probability plot for 1st stage turbine blade in operation
%
% Revision history
% 121219 LDY Code was modified from 'ct7_turbine_blade_analysis/plotWblProbPaperTime.m'.

clear; clc;

% Constant
EFHPerCyc = 1/1.7;        % Engine flight hour per cycle, [h/cyc]

% Parameters (JMP results)
alpha95low = 13786.0;    % Lower 95%
alpha95up = 24134.4;     % Upper 95%
alpha = 18240.6;
beta = 7;

% Fractured blade POF (Minitab results)
cycFail = 5829;    % [cyc]
pof = 0.00273116;

% Domain
X = linspace(3e3, 2e4, 10);

% Probability plot
plot(X*EFHPerCyc, X, '-', 'LineWidth', 2); hold on
plot(cycFail*EFHPerCyc, wblinv(pof, alpha, beta), 'ok', 'MarkerFaceColor', 'k');
hold off

% Format
grid on
axis([3e3, 1.5e4, -inf, inf]);
set(gca, 'XTick', [3000, 5000, 7500, 10000, 15000]);
pLabel = [0.001, 0.003, 0.01, 0.03, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
set(gca, 'YTick', wblinv(pLabel, alpha, beta));
set(gca, 'YTickLabel', pLabel*100);
set(gca, 'FontSize', 14);
set(gca, 'FontWeight', 'bold');

xl = xlabel('TSN (h)');
set(xl, 'FontSize', 15);
set(xl, 'FontWeight', 'bold');
yl = ylabel('Probability (%)');
set(yl, 'FontSize', 15);
set(yl, 'FontWeight', 'bold');