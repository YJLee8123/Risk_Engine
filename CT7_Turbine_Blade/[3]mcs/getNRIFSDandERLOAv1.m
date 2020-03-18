% Using Monte Carlo simulation, calculate NRIFSD and ERLOA of CT7-9C engine
% due to turbine blade fracture. Risk indices are calculated up to current
% engine operation limit.
%
% Revision history
% 120519 LDY Code was modified from 'getNRIFSDandERLOA220v3.m'.

clear; clc;

% Set default.
KAFDataOnly = 0;          % 0: include GE data; 1: use only KAF data
remCycEng = 4e4;          % Remaining engine cycle until operation limit, [cyc]
EFHDepot = 3000;          % Time interval for depot level maintenance, [h]
EFHBladeAtRisk = 3000;    % Blade time greater than this, the module is at risk, [h]
EFHDepotAtRisk = 1000;    % Within this time, modules w/ blades at risk visit depot, [h]

% Constant
EFHPerCyc = 1/1.7;        % Engine flight hour per cycle, [h/cyc]
sfNRIFSD = 1;             % NRIFSD Severity factor (1/1 NRIFSD observed)
sfERLOA = 0.036;          % Historical dual engine landing factor
nrifsdCriteria = 0.05;    % USAF NRIFSD criteria, [/100K EFH]
erloaCriteria = 0.5;      % USAF ERLOA criteria
nBlade1stTurbine = 34;    % Number of blades in the 1st stage turbine

% Calculated constant
cycDepot = EFHDepot/EFHPerCyc;                % [h] => [cyc]
cycBladeAtRisk = EFHBladeAtRisk/EFHPerCyc;    % [h] => [cyc]
cycDepotAtRisk = EFHDepotAtRisk/EFHPerCyc;    % [h] => [cyc]

% Constant - MCS
nrand = 1e7;

% Data --------------------------------------------------------------------
data = xlsread('../[1]data_preprocessing/120619_ct7_turbine_blade_usage_data.xlsx');
acID = data(:, 1);       % Aircraft ID
engID = data(:, 2);      % Left or right engine
tso = data(:, 5);        % Hot section module TSO, [cyc]
partID = data(:, 6);     % 0: Blade; 1: Damper
cycPart = data(:, 7);    % Cycle used, [cyc]
nPart = data(:, 8);      % Number of part with the same time of use

% Get the population at risk.
idxPAR = ~isnan(acID);    % NaN means removed modules in depot.
acID = acID(idxPAR);
engID = engID(idxPAR);
partID = partID(idxPAR);

% Get the number of turbine modules pupulation at risk.
nAC = numel(unique(acID));    % Number of aircraft
nModule = nAC*2;              % CN-235 has two engines for each aircraft.

% Part ID for blades is zero.
idxBladeAll = partID == 0;

% Webull model ------------------------------------------------------------
% Parameters from Weibayes analysis
% Shape parameter
beta = 5;

% Scale parameter
if KAFDataOnly
    alpha = 25584.8;    % KAF data only
else
    alpha = 64435.7;    % Including GE data
end

% Time to failure
TTF = @(X) alpha*(log(1./(1 - X))).^(1/beta);

% MCS ---------------------------------------------------------------------
% Initialize variables for post-processing.
% TSO of all module
tsoPerModule = zeros(nModule, 1);

% POF per module
pofPerModule = zeros(nModule, 10);

for i = 1:nModule
    % Get necessary indices. ----------------------------------------------
    % Index for current aircraft
    idxAC = acID == ceil(i/2);
    
    % index for turbine module with the same engine ID
    if rem(i, 2) == 0
        idxModuleAll = engID == 2;
    else
        idxModuleAll = engID == 1;
    end
    
    % index for current turbine module
    idxModule = logical(idxAC.*idxModuleAll);
    
    % Index for blades in the current turbine module
    idxBlade = logical(idxModule.*idxBladeAll);
    
    % Get blade information. ----------------------------------------------
    % Cycles for blades in the current module
    cycBlade = cycPart(idxBlade);
    
    % Number of blades for each group in the current module
    nBlade = nPart(idxBlade);
    
    % Number of groups of blade with different cycles in the current module
    nBladeGroup = numel(cycBlade);
    
    % Get depot visit schedule. -------------------------------------------
    % TSO of the current module
    tsoPerModule(i) = unique(tso(idxModule));
    
    % Modules with recycled blades which operate over certain cycels need to
    % visit depot early.
    isModuleAtRisk = false;
    if sum(cycBlade > cycBladeAtRisk) ~= 0
        isModuleAtRisk = true;
    end
    
    % Hot section module cycles for initial depot visit
    if isModuleAtRisk
        tcinit = tsoPerModule(i) + cycDepotAtRisk;
        tcfinal = remCycEng + cycDepotAtRisk;
    else
        tcinit = max([1, ceil(tsoPerModule(i)/cycDepot)])*cycDepot;
        tcfinal = remCycEng + tsoPerModule(i);
    end
    
    % Cycles for depot visit
    tc = tcinit:cycDepot:tcfinal;
    if tc(end) ~= tcfinal
        tc = [tc, tcfinal];
    end
    
    % Do calculation for each depot interval. -----------------------------
    for j = 1:numel(tc)
        % Set blade usage variables.
        if j == 1
            % Remaining cycles until depot visit
            remCycBlade = tc(1) - tsoPerModule(i);
            
            % Number of blades for each group in the current module
            nBladePerModule = nBlade;
        else
            remCycBlade = tc(j) - tc(j-1);
            
            % Assume all blade replacement
            cycBlade = 0;
            nBladePerModule = nBlade1stTurbine;
            nBladeGroup = 1;
        end
        
        % Expected number of blade failure
        % Each module may have multiple blade cycles; thus, a vector was
        % used to save calculated number of fractured blades.
        nFailPerBlade = zeros(nBladeGroup, 1);
        
        % Do calculation for each module consecutively. -------------------
        for k = 1:nBladeGroup
            % Initial cycle
            cycinit = cycBlade(k);
            
            % Blade cycle at depot visit
            cycBladeDepot = cycinit + remCycBlade;
            
            % Step 1 ======================================================
            % Realize random numbers.
            T = rand(nrand, 1);
            
            % Time to failure
            ttf = TTF(T);
            
            % Step 2 & 3 ==================================================
            if cycinit ~= 0    % Check non-zero starting point.
                % Check TTF before current cycle.
                idxUnreal = ttf < cycinit;
                nUnreal = sum(idxUnreal);
                
                % Do MCS for unreal samples.
                if nUnreal ~= 0
                    while nUnreal > 0
                        T = rand(nUnreal, 1);
                        ttf(idxUnreal) = ttf(idxUnreal) + TTF(T);
                        
                        idxUnreal = ttf < cycinit;
                        nUnreal = sum(idxUnreal);
                    end
                end
            end
            
            % Step 4 ======================================================
            % Check failure before inspection.
            idxFail = ttf < cycBladeDepot;
            nFail = sum(idxFail);
            
            % Count no-good samples.
            nFailPerBlade(k) = nFailPerBlade(k) + nFail;
        end
        
        % Probability of the failure of each blade in near future from now
        pofPerBlade = nFailPerBlade/nrand;
        
        % Change in fracture risk for each module's set of blades.
        pofPerModule(i, j) = 1 - prod((1 - pofPerBlade).^nBladePerModule);
    end
end

% Get initiating events.
initEvent = sum(pofPerModule(:));

% Calculate risk indices. -------------------------------------------------
% NRIFSD events
nrifsdEvent = initEvent*sfNRIFSD;

% ERLOA events
erloaEvent = nrifsdEvent*sfERLOA;

% Remaining engine flight cycle
remCycPerModule = remCycEng*nModule;
remCyc = sum(remCycPerModule);

% Remaining engine flight hour (EFH)
remEFH = remCyc*EFHPerCyc;

% NRIFSD per 100k EFH
nrifsd = nrifsdEvent./remEFH*1e5;

% Print results. ----------------------------------------------------------
disp('===== CT7-9C =====');
disp(['Operation Limit = ', num2str(remCycEng)]);
disp(['Initiating Events = ', num2str(initEvent)]);
disp(['NRIFSD Events = ', num2str(nrifsdEvent)]);
disp(['NRIFSD/100K EFH = ', num2str(nrifsd), ' (< ', num2str(nrifsdCriteria), ')']);
disp(['ERLOA Events = ', num2str(erloaEvent), ' (< ', num2str(erloaCriteria), ')']);