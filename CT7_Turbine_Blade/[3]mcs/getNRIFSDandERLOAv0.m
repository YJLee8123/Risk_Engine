% Using Monte Carlo simulation, calculate NRIFSD and ERLOA of CT7-9C
% engine due to turbine blade fracture. Risk indices are calculated up to
% current depot visit.
%
% Revision history
% 120519 LDY Code was modified from 'getNRIFSDandERLOA220v3.m'.

clear; clc;

% Constant
EFHDepot = 3000;      % Time for depot level maintenance, [h]
EFHPerCyc = 1/1.7;    % Engine flight hour per cycle, [h/cyc]
sfNRIFSD = 1;         % NRIFSD Severity factor (1/1 NRIFSD observed)
sfERLOA = 0.03;       % Historical dual engine landing factor

% Calculated constant
cycDepot = EFHDepot/EFHPerCyc;    % Cycle for depot level maintenance

% Constant - MCS
nrand = 1e6;

% Data --------------------------------------------------------------------
data = xlsread('../[1]data_preprocessing/120619_ct7_turbine_blade_usage_data.xlsx');
acID = data(:, 1);       % Aircraft ID
engID = data(:, 2);      % Left or right engine
tso = data(:, 5);        % Hot section module TSO, [cyc]
partID = data(:, 6);     % 0: Blade; 1: Damper
cycPart = data(:, 7);    % Cycle used, [cyc]
nPart = data(:, 8);      % Number of part with the same time of use

% Get the population at risk.
idxPAR = ~isnan(acID);
acID = acID(idxPAR);    % Remove modules in depot.
engID = engID(idxPAR);
partID = partID(idxPAR);

% Get the number of turbine modules pupulation at risk.
nAC = numel(unique(acID));    % Number of aircraft
nModule = nAC*2;              % CN-235 has two engines for each aircraft.

% Part ID for blades is zero.
idxAllBlade = partID == 0;

% Webull model ------------------------------------------------------------
% Parameters from Weibayes analysis
alpha = 18240.6;
beta = 7;

% Time to failure
ttf = @(X) alpha*(log(1./(1 - X))).^(1/beta);

% MCS ---------------------------------------------------------------------
% Initialize variables for post-processing.
% TSO of all module
tsoPerModule = zeros(nModule, 1);

% Remaining engine flight cycle
remCycPerModule = zeros(nModule, 1);

% Each module may have multiple blade cycles; thus, two dimensional initial
% matrix was used to save calculated number of fractured blades.
nFailPerBlade = zeros(nModule, 5);
nBladePerModule = zeros(nModule, 5);

for i = 1:nModule
    % Index for current aircraft
    idxAC = acID == ceil(i/2);
    
    % index for current turbine module
    if rem(i, 2) == 0
        idxModule = engID == 2;
    else
        idxModule = engID == 1;
    end
    
    % TSO of the current module
    tsoPerModule(i) = unique(tso(logical(idxAC.*idxModule)));
    
    % Remaining cycles to be flown
    if tsoPerModule(i) <= cycDepot
        remCycPerModule(i) = cycDepot - tsoPerModule(i);
    else
        remCycPerModule(i) = 2*cycDepot - tsoPerModule(i);
    end
    
    % Index for blades in the current turbine module
    idxBlade = logical(idxAC.*idxModule.*idxAllBlade);
    
    % Cycles for blades in the current module
    cycBlade = cycPart(idxBlade);
    nBlade = nPart(idxBlade);
    
    % Number of different blade cycles in the current module
    nBladeGroup = numel(cycBlade);
    
    % Save the nuber of blades for risk calculation.
    nBladePerModule(i, 1:nBladeGroup) = nBlade;
    
    % Do calculation for each module consecutively.
    for j = 1:nBladeGroup
        % Initial cycle
        cycinit = cycBlade(j);
        
        % Blade cycle at depot visit
        cycBladeDepot = cycinit + remCycPerModule(i);
        
        % Step 1 ==========================================================
        % Realize random numbers.
        T = rand(nrand, 1);
        
        % Time to failure
        t = ttf(T);
        
        % Step 2 & 3 ======================================================
        if cycinit ~= 0    % Check non-zero starting point.
            % Check TTF before current cycle.
            idxUnreal = t < cycinit;
            nUnreal = sum(idxUnreal);
            
            % Do MCS for unreal samples.
            if nUnreal ~= 0
                while nUnreal > 0
                    T = rand(nUnreal, 1);
                    t(idxUnreal) = t(idxUnreal) + ttf(T);
                    
                    idxUnreal = t < cycinit;
                    nUnreal = sum(idxUnreal);
                end
            end
        end
        
        % Check failure before inspection.
        idxFail = t < cycBladeDepot;
        nFail = sum(idxFail);
        
        % Count no-good samples.
        nFailPerBlade(i, j) = nFailPerBlade(i, j) + nFail;
        
        % Step 4 ==========================================================
        % Do MCS for failed parts.
        if nFail ~= 0
            while nFail > 0
                % Resampling
                T = rand(nFail, 1);
                t(idxFail) = t(idxFail) + ttf(T);
                
                % Check validity.
                idxFail = t < cycBladeDepot;
                nFail = sum(idxFail);
            end
        end
    end
end

% Probability of the failure of each blade in near future from now
pofPerBlade = nFailPerBlade/nrand;

% Change in fracture risk for each module's set of blades.
pofPerModule = 1 - prod((1 - pofPerBlade).^nBladePerModule, 2);

% Get initiating events.
initEvent = sum(pofPerModule);

% Calculate risk indices. -------------------------------------------------
% NRIFSD events
nrifsdEvent = initEvent*sfNRIFSD;

% ERLOA events
erloaEvent = nrifsdEvent*sfERLOA;

% Remaining engine flight cycle
remCyc = sum(remCycPerModule);

% Remaining engine flight hour (EFH)
remEFH = remCyc*EFHPerCyc;

% NRIFSD per 100k EFH
nrifsd = nrifsdEvent./remEFH*1e5;

% Print results. ----------------------------------------------------------
disp('======== F100-PW-220 ========');
disp(['Initiating Events = ', num2str(initEvent)]);
disp(['NRIFSD Events = ', num2str(nrifsdEvent)]);
disp(['NRIFSD/100K EFH = ', num2str(nrifsd, '%1.3f')]);
disp(['ERLOA Events = ', num2str(erloaEvent)]);