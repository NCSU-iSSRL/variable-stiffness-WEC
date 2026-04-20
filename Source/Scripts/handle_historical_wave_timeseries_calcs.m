clear;clc;
% simDataFile = "C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\wecSim_projects\ONR\p3_1m\results\P3_1m_sim_sweep_resultsOnly_2025_07_24_17_55_52.mat";
simDataFile = "C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\wecSim_projects\ONR\p3_1m\results\P3_1m_TG_sim_sweep_resultsOnly_2025_09_09_00_32_42.mat";

historicalDataFiles = dir("E:\CDIP_buoy_data\192*.nc");

buoyUptimeRatio_combined = [];
avgPower_combined = [];
manualHydImpedance = 6; % manual cracking pressure or gear ratio, depending on PTO type
drawPlots = 0;

for q = 1:length(historicalDataFiles)
    historicalDataFile = [historicalDataFiles(q).folder, '\', historicalDataFiles(q).name];
    CDIP_ID = strsplit(historicalDataFiles(q).name, 'p1_');
    CDIP_ID = str2double(CDIP_ID{1});
    [capacityFactors, buoyUptimeRatio] = historical_wave_timeseries_sim_calc(simDataFile, historicalDataFile, 70, manualHydImpedance, drawPlots);
    buoyUptimeRatio_combined(end+1, :) = [CDIP_ID, buoyUptimeRatio];
    avgPower_combined(end+1, :) = [CDIP_ID, capacityFactors(:,3)'];
end

buoyUptimeRatio_combined(:,5) = buoyUptimeRatio_combined(:,4) - buoyUptimeRatio_combined(:,2) % [CDIP ID, manual static setting, best static setting, fully adaptive, improvement from static to fully adaptive]
avgPower_combined(:,5) = (avgPower_combined(:,4) - avgPower_combined(:,2)) ./ avgPower_combined(:,4) * 100 % [CDIP ID, manual static setting, best static setting, fully adaptive, % increase from static to fully adaptive]

%% print latex results table

latexTableString = '';

for q = 1:length(avgPower_combined)
    switch avgPower_combined(q,1) % stations to add to latex formatted table string
        case {98 147 154 157 160 192 194 204 256 269}
            latexTableString = [latexTableString, ...
                sprintf('%03d & %.2f & %.2f & %.2f & %+.2f \\\\\n\\hline\n', avgPower_combined(q, :))];
    end
end

latexTableString