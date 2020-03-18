% Data preprocessing for the Weibull analysis and historam of CT7 engine
% turbine first stage blade
%
% Revision history
% 120619 LDY Code was created.

clear; clc;

% Constant
nDepotMax = 3;

% Data
data = xlsread('120619_ct7_turbine_blade_usage_data.xlsx');

% Disassemble data.
partID = data(:, 6);
cycPart = data(:, 7);
nPart = data(:, 8);
failed = data(:, 9);

% Part ID for blades is zero.
idxBlade = partID == 0;

% Get the number of blade groups with the same cycle.
nBladeGroup = sum(idxBlade);

% Get the data of blades for each group of blades.
cycBlade = cycPart(idxBlade);
nBlade = nPart(idxBlade);
failedBlade = failed(idxBlade);

% Get the cumulative sum of each blade group.
nBladeCum = cumsum(nBlade);

% Initialize variables for Weibull analysis.
nBladeAll = sum(nBlade);
cycEachBlade = zeros(nBladeAll, 1);
failedEach = zeros(nBladeAll, 1);

for i = 1:nBladeGroup
    if i == 1
        idx = 1:nBladeCum(i);
    else
        idx = (nBladeCum(i-1) + 1):nBladeCum(i);
    end
    
    cycEachBlade(idx) = cycBlade(i);
    failedEach(idx) = failedBlade(i);
end

% Save as a csv file for Weibull analysis.
csvwrite('ct7_tb_tsn_cyc.csv', [cycEachBlade, failedEach]);