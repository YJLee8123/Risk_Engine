% Data preprocessing for the Weibull analysis and historam of CT7 engine
% turbine first stage blade
%
% Revision history
% 120619 LDY Code was created.
% 121219 LDY Consider censored data mentioned in the letter from GE on
%            November 29, 2019.

clear; clc;

% Constant
nDepotMax = 3;            % Maximum number of depot visit for H/S modules
nBlade1stTurbine = 34;    % Number of blades in the 1st stage turbine

% Data from ROKAF ---------------------------------------------------------
data = xlsread('120619_ct7_turbine_blade_usage_data.xlsx');
partID = data(:, 6);     % 0: Blade; 1: Damper
cycPart = data(:, 7);    % Cycle used, [cyc]
nPart = data(:, 8);      % Number of part with the same time of use
failed = data(:, 9);     % 0: censored; 1: fractured

% Part ID for blades is zero.
idxBlade = partID == 0;

% Get the number of blade groups with the same cycle.
nBladeGroupKAF = sum(idxBlade);

% Get the data of blades for each group of blades.
cycBladeKAF = cycPart(idxBlade);
nBladeKAF = nPart(idxBlade);
failedBladeKAF = failed(idxBlade);

% Data from GE letter -----------------------------------------------------
% *************************************************************************
% GE is aware of one other documented CT7 turboprop shank separation in
% October 1996 with a thin damper, with a total turboprop thin damper
% operating time of approximately 21 million hours.
%**************************************************************************
% EFH to cycle conversion factor
% Ref) IATA, 2017, Airline Maintenance Cost Executive Commentary, p.20.
%      See FH/FC ratio for TP (Truboprop).
EFHPerCyc = 1;    % Engine flight hour per cycle, [h/cyc]

% Failure data (choosed for conservative analysis)
cycBladeFail96 = 1000;    % [cyc]

% Maximum operating cycle of hot section is dertermined by the part of the
% lowest service life (2nd turbine after cooling plate).
cycBladeMax = 9800;     % Max cycle of 2nd turbine aft cooling plate, [cyc]

% Estimated parameters for blade replacement cycles using KAF data
alpha = 7540;    % Scale parameter, [cyc]
beta = 4.8;      % Shape parameter

% Blade replacement cycles model
pd = makedist('Weibull', 'a', alpha, 'b', beta);
ccyBladeModel = truncate(pd, 0, cycBladeMax);    % Truncated model

% Get censored data.
nBladeGroupGE = 3000;
%cycBladeGE = cycBladeMax*rand(nBladeGroupGE, 1);      % Uniform dist.
cycBladeGE = ccyBladeModel.random(nBladeGroupGE, 1);
nBladeGE = nBlade1stTurbine*ones(nBladeGroupGE, 1);
failedBladeGE = zeros(nBladeGroupGE, 1);               % Censored

% Round cycles.
cycBladeGE = round(cycBladeGE);

% Total operating time from GE
cycBladeGEall = sum(cycBladeGE*EFHPerCyc);

% Add data from GE letter -------------------------------------------------
nBladeGroup = nBladeGroupKAF + nBladeGroupGE + 1;
cycBlade = [cycBladeKAF; cycBladeGE; cycBladeFail96];
nBlade = [nBladeKAF; nBladeGE; 1];
failedBlade = [failedBladeKAF; failedBladeGE; 1];

% Cycle and censoring idex of individual blade ----------------------------
% Get the cumulative sum of each blade group.
nBladeCum = cumsum(nBlade);

% Initialize variables for Weibull analysis.
nBladeAll = sum(nBlade);
cycEachBlade = zeros(nBladeAll, 1);
failedEach = zeros(nBladeAll, 1);

% Get the cycle and censoring idex from each blade group.
for i = 1:nBladeGroup
    if i == 1
        idx = 1:nBladeCum(i);
    else
        idx = (nBladeCum(i-1) + 1):nBladeCum(i);
    end
    
    cycEachBlade(idx) = cycBlade(i);
    failedEach(idx) = failedBlade(i);
end

% Save data for further analysis. -----------------------------------------
% Save as a csv file for Weibull analysis.
csvwrite('ct7_tb_tsn_cyc_v1.csv', [cycEachBlade, failedEach]);

% Write text file for data summary.
fileID = fopen('v1_info.txt','w');
fprintf(fileID, 'Number of blade group from GE: %d \n',nBladeGroupGE);
fprintf(fileID, 'Number of blades for each group: %d \n', nBlade1stTurbine);
fprintf(fileID, 'Scale param. for blade replacement cycle: %d \n', alpha);
fprintf(fileID, 'Shape param. for blade replacement cycle: %.1f \n', beta);
fprintf(fileID, 'Total operating time from GE: %dh',cycBladeGEall);
fclose(fileID);