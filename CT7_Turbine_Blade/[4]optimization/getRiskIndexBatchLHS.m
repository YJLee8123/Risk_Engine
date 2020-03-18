% Parametric study mainly for the effect of TCI and inspection interval

clear; clc;

% Add path for MCS function
addpath('../[3]mcs');

% Constant
nExp = 1000;    % Number of experiments

% Parameters fixed

% Parameters
KAFDataOnly = 0;                % 0: include GE data; 1: use only KAF data
remCycEng = [2e4, 5e4];         % Remaining engine cycle until operation limit, [cyc]
EFHDepot = [2e3, 6e3];          % Time interval for depot level maintenance, [h]
EFHBladeAtRisk = [1e3, 3e3];    % Blade time greater than this, the module is at risk, [h]
EFHDepotAtRisk = [1e3, EFHBladeAtRisk(2)];    % Within this time, modules w/ blades at risk visit depot, [h]

% Latin hypercube sample
x = lhsdesign(nExp, 4, 'criterion', 'maximin');

% Get experimental conditions.
X1 = x(:, 1)*(remCycEng(2) - remCycEng(1)) + remCycEng(1);
X2 = x(:, 2)*(EFHDepot(2) - EFHDepot(1)) + EFHDepot(1);
X3 = x(:, 3)*(EFHBladeAtRisk(2) - EFHBladeAtRisk(1)) + EFHBladeAtRisk(1);
X4 = x(:, 4)*(EFHDepotAtRisk(2) - EFHDepotAtRisk(1)) + EFHDepotAtRisk(1);

% Consolidate experimental conditions for plot.
X = [X1, X2, X3, X4];

% Initialize outputs.
nrifsd = zeros(nExp, 1);
erloa = zeros(nExp, 1);

% Do calculation
parfor i = 1:nExp
    % Reassign variables for parallel for loops.
    X1i = X1(i);
    X2i = X2(i);
    X3i = X3(i);
    X4i = X4(i);
    
    % Options
    % 'KAFDataOnly' - 0: include GE data; 1: use only KAF data
    % 'remCycEng' - remaining engine cycle util operation limit, [cyc]
    % 'EFHDepot' - time interval for depot level maintenance, [h]
    % 'EFHBladeAtRisk' - blade time greater than this, the module is at
    %                    risk, [h]
    % 'EFHDepotAtRisk' - within this time, modules w/ blades at risk visit
    %                    depot, [h]
    % 'verbose' - show progress if true
    
    [nrifsd_i, erloa_i] = getNRIFSDandERLOAv2b( ...
        'KAFDataOnly', KAFDataOnly, ...
        'remCycEng', X1i, ...
        'EFHDepot', X2i, ...
        'EFHBladeAtRisk', X3i, ...
        'EFHDepotAtRisk', X4i, ...
        'verbose', 0);
    
    % Collect results.
    nrifsd(i) = nrifsd_i;
    erloa(i) = erloa_i;
    
    % Display progress.
    disp([num2str(i), '/', num2str(nExp)]);
end

% Save ouputs.
save('riskIndexLHS', 'X', 'nrifsd', 'erloa');

% Write csv file.
csvwrite('riskIndexLHS.csv', [X, nrifsd, erloa]);