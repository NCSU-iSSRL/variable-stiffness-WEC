% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.25:0.5:3.25;
wavePeriods = 2:0.5:8;
regulator_set_pressure_PSI_in = 3;
%regulator_set_pressure_PSI_in = 10:5:50;
powerMatrix = nan(length(waveHeights), length(wavePeriods), length(regulator_set_pressure_PSI_in));
results = [];
simData = {};

simSweep = 1; % flag used in wecSimInputFile

fid = fopen('wecSimInputFile.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

for waveHeightQ = 1:length(waveHeights)
    for regulatorQ = 1:length(regulator_set_pressure_PSI_in)
        for wavePeriodQ = 1:length(wavePeriods)
            results(end+1,:) = [nan nan nan nan nan];
            waveHeight = waveHeights(waveHeightQ);
            wavePeriod = wavePeriods(wavePeriodQ);
            regulator_set_pressure_PSI = regulator_set_pressure_PSI_in(regulatorQ);
            try
                wecSim;
                %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                avgPower = get(logsout, 'mech_Watt_avg');
                HP_strain = get(logsout, 'HP_strain');
                results(end,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, mean(avgPower.Values.Data(end-1000:end)), max(HP_strain.Values.Data(end-1000:end))];
                simData{end+1}.wavePeriod = wavePeriod;
                simData{end}.waveHeight = waveHeight;
                simData{end}.regulator_set_pressure_PSI = regulator_set_pressure_PSI;
                simData{end}.signalLogs = logsout;
                powerMatrix(waveHeightQ, wavePeriodQ, regulatorQ) = mean(avgPower.Values.Data(end-1000:end));
            end
        end
    end
end
simSweep = 0; % flag used in wecSimInputFile

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\P3_sim_sweep_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "powerMatrix", "waveHeights", "wavePeriods", "regulator_set_pressure_PSI_in", "wecSimInputScript", "runTimeStamp");

% save all sim output data (large files, do not put on cloud storage)
saveLargeData = 1;
switch getenv('COMPUTERNAME')
    case {"VERMILLIONLAB13", "MAE-DT-001"}
        dataSaveFolder = 'D:\research_data\WEC_sim_data\plunger3_buoy_1m';
    otherwise
        % add other computers here
        disp('!!! No large data save folder specified !!!')
        saveLargeData = 0;
end

if saveLargeData
    filename = sprintf('%s\\P3_sim_sweep_full_%s.mat', dataSaveFolder, runTimeStamp);
    save(filename, "results", "simData");
end

%% plot

% figure(42)
% clf
% ax1 = subplot(1,2,1);
% hold on
% grid on
% %legend()
% xlabel('Wave period (s)')
% ylabel('Time-averaged power (W)')
% %ylim([50 500])
% 
% 
% ax2 = subplot(1,2,2);
% hold on
% grid on
% legend()
% xlabel('Wave period (s)')
% ylabel('Non-dimensionalized power (P_{WEC}/P_{WAVE})')
% %ylim([0 0.35])
% 
% indices = ~isnan(results(:,1));
% waveHeights = unique(results(indices,1))';
% regulatorSettings = unique(results(indices,3))';
% 
% %sgtitle(sprintf('H0 = %.2f m -- %s', waveHeights, runTimeStamp), 'Interpreter','none')
% 
% sgtitle(runTimeStamp, 'Interpreter','none')
% for waveHeight = waveHeights
%     for regulatorSetting = regulatorSettings
%         indices = results(:,1) == waveHeight & results(:,3) == regulatorSetting;
%         subplot(1,2,1)
%         plot(results(indices,2), results(indices,4), 'DisplayName', ...
%             sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
% 
%         charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
%         wavePower = 1000*9.81^2/64/pi * waveHeight^2 * results(indices,2) * charLength;
%         subplot(1,2,2)
%         plot(results(indices,2), results(indices,4)./wavePower, 'DisplayName', ...
%             sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
%     end
% end
% 
% linkaxes([ax1 ax2], 'x')
% set(gcf, 'Position', [131         635        1555         627])
% for q = 1:3
%     fontsize('increase')
% end
% copygraphics(gcf, 'Resolution',300)


%% contour plots

indices = ~isnan(results(:,1));
waveHeights = unique(results(indices,1))';
regulatorSettings = unique(results(indices,3))';

figNum = 11;
for regulatorSetting = regulatorSettings
    indices = results(:,3) == regulatorSetting;
    figure(figNum)
    clf

    contourf(wavePeriods, waveHeights, powerMatrix, 20)
    xlabel('Wave period (s)')
    ylabel('Wave height (m)')

    figNum = figNum + 1;
end