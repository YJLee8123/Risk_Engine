% Plot risk index vs. the most important factor.

clear; clc;

% Add path for MCS function
addpath('../[3]mcs');

% Constant
nrifsdCriteria = 0.05;    % USAF NRIFSD criteria, [/100K EFH]
erloaCriteria = 0.5;      % USAF ERLOA criteria

% Parameters fixed
remCycEng = 4e4;           % Remaining engine cycle until operation limit, [cyc]
EFHDepotRecycled = 2e3;    % Within this time, modules w/ recycled blades visit depot, [h]
cycBladeAtRisk = 5e3;      % Blade cycle greater than this, the module is at risk, [cyc]

% Parameters to be studied
EFHDepot = linspace(2e3, 8e3, 15);    % Time interval for depot level maintenance, [h]

% Get experimental conditions.
X1 = EFHDepot;

% Initialize outputs.
nrifsd = zeros(size(X1));
erloa = zeros(size(X1));

% Number of experiment
nExp = numel(nrifsd);

% Do calculation
for i = 1:nExp
    % Reassign variables for parallel for loops.
    X1i = X1(i);
    
    % Options
    % 'remCycEng' - remaining engine cycle util operation limit, [cyc]
    % 'EFHDepot' - time interval for depot level maintenance, [h]
    % 'cycDepotRecycled' - within this cycle, modules w/ recycled blades
    %                      visit depot, [cyc]
    % 'cycBladeAtRisk' - blade cycle greater than this, the module is at
    %                    risk, [cyc]
    % 'verbose' - show progress if true
    
    [nrifsd_i, erloa_i] = getNRIFSDandERLOAv2b( ...
        'remCycEng', remCycEng, ...
        'EFHDepot', X1i, ...
        'EFHDepotRecycled', EFHDepotRecycled, ...
        'cycBladeAtRisk', cycBladeAtRisk, ...
        'verbose', 0);
    
    % Collect results.
    nrifsd(i) = nrifsd_i;
    erloa(i) = erloa_i;
    
    % Display progress.
    disp([num2str(i), '/', num2str(nExp)]);
end

% Variables for plot
X = X1;
Y = nrifsd;
Yrc = nrifsdCriteria*ones(size(X));

% Ris criteria for "surface" plot
idxSafe = nrifsd < nrifsdCriteria;
Ycs = Y(idxSafe);     % Safe points
Ycd = Y(~idxSafe);    % Dangerous points

% Plot
hcs = plot(X(idxSafe),  Ycs, 'ob'); hold on
hcd = plot(X(~idxSafe), Ycd, 'or');
plot(X, Yrc, '--k', 'LineWidth', 2); hold off

text(2050, 0.042, 'Safe', 'FontSize', 12);
text(2050, 0.058, 'Unsafe', 'FontSize', 12);
%text(4500, 0.2, 'Unsafe', 'FontSize', 12);

% Format
grid on
set(gca, 'FontSize', 12);
set(gca, 'FontWeight', 'bold');
%set(hc, 'EdgeColor', 'none', 'FaceColor', 'r');
set([hcs, hcd], 'MarkerSize', 7);
set(hcs, 'MarkerFaceColor', 'b');
set(hcd, 'MarkerFaceColor', 'r');

xl = xlabel('Depot Interval (h)');
set(xl, 'FontSize', 13);
set(xl, 'FontWeight', 'bold');
yl = ylabel('NRIFSD/100k EFH');
set(yl, 'FontSize', 13);
set(yl, 'FontWeight', 'bold');