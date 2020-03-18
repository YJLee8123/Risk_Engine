% Plot risk index vs. the most important factor.

clear; clc;

% Add path for MCS function
addpath('../[3]mcs');

% Constant
nrifsdCriteria = 0.05;    % USAF NRIFSD criteria, [/100K EFH]
erloaCriteria = 0.5;      % USAF ERLOA criteria

% Parameters fixed
KAFDataOnly = 0;         % 0: include GE data; 1: use only KAF data
remCycEng = 4e4;         % Remaining engine cycle until operation limit, [cyc]
EFHBladeAtRisk = 3e3;    % Blade time greater than this, the module is at risk, [h]
EFHDepotAtRisk = 1e3;    % Within this time, modules w/ blades at risk visit depot, [h]

% Parameters to be studied
EFHDepot = linspace(2e3, 6e3, 15);    % Time interval for depot level maintenance, [h]

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
    % 'KAFDataOnly' - 0: include GE data; 1: use only KAF data
    % 'remCycEng' - remaining engine cycle util operation limit, [cyc]
    % 'EFHDepot' - time interval for depot level maintenance, [h]
    % 'EFHDepotAtRisk' - within this time, modules w/ blades at risk visit
    %                    depot, [h]
    % 'EFHBladeAtRisk' - blade time greater than this, the module is at
    %                    risk, [h]
    % 'verbose' - show progress if true
    
    [nrifsd_i, erloa_i] = getNRIFSDandERLOAv2b( ...
        'KAFDataOnly', KAFDataOnly, ...
        'remCycEng', remCycEng, ...
        'EFHDepot', X1i, ...
        'EFHBladeAtRisk', EFHBladeAtRisk, ...
        'EFHDepotAtRisk', EFHDepotAtRisk, ...
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
if KAFDataOnly
    hcd = plot(X(~idxSafe), Ycd, 'or'); hold on
    plot(X, Yrc, '--k', 'LineWidth', 2); hold off
    text(5500, 0.5, 'Unsafe', 'FontSize', 12);
    
    set(hcd, 'MarkerSize', 7);
    set(hcd, 'MarkerFaceColor', 'r');
else
    hcs = plot(X(idxSafe),  Ycs, 'ob'); hold on
    hcd = plot(X(~idxSafe), Ycd, 'or');
    plot(X, Yrc, '--k', 'LineWidth', 2); hold off
    text(2050, 0.045, 'Safe', 'FontSize', 12);
    text(2050, 0.055, 'Unsafe', 'FontSize', 12);
    
    set([hcs, hcd], 'MarkerSize', 7);
    set(hcs, 'MarkerFaceColor', 'b');
    set(hcd, 'MarkerFaceColor', 'r');
end

% Format
grid on
set(gca, 'FontSize', 12);
set(gca, 'FontWeight', 'bold');

xl = xlabel('Depot Interval (h)');
set(xl, 'FontSize', 13);
set(xl, 'FontWeight', 'bold');
yl = ylabel('NRIFSD/100k EFH');
set(yl, 'FontSize', 13);
set(yl, 'FontWeight', 'bold');