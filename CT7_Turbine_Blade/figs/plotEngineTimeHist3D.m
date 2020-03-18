% Plot 3D histogram of TSN and TSO.

clear; clc;

% Constant
EFHPerCyc = 1/1.7;    % Engine flight hour per cycle, [h/cyc]

% Data
data = xlsread('../[1]data_preprocessing/120619_ct7_turbine_blade_usage_data.xlsx');
moduleSN = data(:, 3);     % Module serial number
tsnModule = data(:, 4);    % Time since new, [cyc]
tsoModule = data(:, 5);    % Hot section module TSO, [cyc]

% Remove duplicated values
[C, IA] = unique(moduleSN);
tsn = tsnModule(IA);
tso = tsoModule(IA);

% NaN in tso means under depot maintenance; thus, tso equal to zero.
tso(isnan(tso)) = 0;

% Plot
hist3([tsn, tso]);

% Format
grid on
set(get(gca, 'child'), 'FaceColor', 'interp', 'CDataMode', 'auto');
set(gca, 'FontSize', 14);
set(gca, 'FontWeight', 'bold');

%xl = xlabel('TSN (h)');
xl = xlabel('TSN (cyc)');
set(xl, 'FontSize', 15);
set(xl, 'FontWeight', 'bold');
%yl = ylabel('TSO (h)');
yl = ylabel('TSO (cyc)');
set(yl, 'FontSize', 15);
set(yl, 'FontWeight', 'bold');