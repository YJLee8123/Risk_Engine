% Plot risk indices calculated by 'getRiskIndexBatchLHS.m'.

clear; clc;

% Data
load('riskIndexLHS', 'X', 'nrifsd', 'erloa');

remCycEng = X(:, 1);
EFHDepot = X(:, 2);
EFHDepotRecycled = X(:, 3);
cycBladeAtRisk = X(:, 4);

X = EFHDepot;
Y = EFHDepotRecycled;
Z = nrifsd;

% Plot
h = plot3(X, Y, Z, 'or');

% Format
grid on
set(gca, 'FontSize', 12);
set(gca, 'FontWeight', 'bold');
set(h, 'MarkerSize', 5);
set(h, 'MarkerFaceColor', 'r');

xl = xlabel('Depot Interval (h)');
set(xl, 'FontSize', 13);
set(xl, 'FontWeight', 'bold');
yl = ylabel('Initial Depot Visit (h)');
set(yl, 'FontSize', 13);
set(yl, 'FontWeight', 'bold');
zl = zlabel('NRIFSD/100k EFH');
set(zl, 'FontSize', 13);
set(zl, 'FontWeight', 'bold');