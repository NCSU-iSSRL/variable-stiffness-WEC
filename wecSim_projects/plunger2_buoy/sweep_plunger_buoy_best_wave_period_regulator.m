% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.1;
%wavePeriods = 2:-0.25:0.75;
regulator_set_pressure_PSI_in = 10%7.5:2.5:12.5;
results = [];
simData = {};

bestWavePeriod = 1.75;
simSweep = 1; % flag used in wecSimInputFile

fid = fopen('wecSimInputFile.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

for waveHeight = waveHeights
    for regulator_set_pressure_PSI = regulator_set_pressure_PSI_in
        numConsequtiveWorseRuns = 0;
        bestAvgPower = 0;
        %wavePeriods = bestWavePeriod+0.25:-0.125:0.75;
        wavePeriods = 1.7:-0.1/1:0.9;
        for wavePeriod = wavePeriods
            if numConsequtiveWorseRuns < inf
                results(end+1,:) = [nan nan nan nan nan];
                try
                    wecSim;
                    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                    avgPower = get(logsout, 'mech_Watt_avg');
                    FAM_stretch = get(logsout, 'FAM_stretch');
                    results(end,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, mean(avgPower.Values.Data(end-1000:end)), max(FAM_stretch.Values.Data(end-1000:end))];
                    simData{end+1}.wavePeriod = wavePeriod;
                    simData{end}.waveHeight = waveHeight;
                    simData{end}.signalLogs = logsout;
                end

                if mean(avgPower.Values.Data(end-50:end)) > bestAvgPower
                    bestAvgPower = mean(avgPower.Values.Data(end-1000:end));
                    %bestWavePeriod = wavePeriod;
                    numConsequtiveWorseRuns = 0;
                else
                    numConsequtiveWorseRuns = numConsequtiveWorseRuns + 1;
                end
            end
        end
    end
end
simSweep = 0; % flag used in wecSimInputFile

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\P2_sim_sweep_regulator_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "wecSimInputScript", "runTimeStamp");

% save all sim output data (large files, do not put on cloud storage)
saveLargeData = 1;
switch getenv('COMPUTERNAME')
    case "VERMILLIONLAB13"
        dataSaveFolder = 'C:\Users\cmmcguir\Documents\research_data\WEC_sim_data\plunger2_buoy';
    otherwise
        % add other computers here
        disp('!!! No large data save folder specified !!!')
        saveLargeData = 0;
end

if saveLargeData
    filename = sprintf('%s\\P2_sim_sweep_regulator_full_%s.mat', dataSaveFolder, runTimeStamp);
    save(filename, "results", "simData");
end

%% plot

figure(42)
clf
subplot(1,2,1)
hold on
grid on
%legend()
xlabel('Wave period (s)')
ylabel('Time-averaged power (mW)')
ylim([50 500])


subplot(1,2,2)
hold on
grid on
legend()
xlabel('Wave period (s)')
ylabel('Non-dimensionalized power (P_{WEC}/P_{WAVE})')
ylim([0 0.35])

indices = ~isnan(results(:,1));
waveHeights = unique(results(indices,1))';
regulatorSettings = unique(results(indices,3))';

sgtitle(sprintf('H0 = %.2f m -- %s', waveHeights, runTimeStamp), 'Interpreter','none')

for waveHeight = waveHeights
    for regulatorSetting = regulatorSettings
        indices = results(:,1) == waveHeight & results(:,3) == regulatorSetting;
        subplot(1,2,1)
        plot(results(indices,2), results(indices,4)*1000, 'DisplayName', ...
            sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
        
        charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
        wavePower = 1000*9.81^2/64/pi * waveHeight^2 * results(indices,2) * charLength;
        subplot(1,2,2)
        plot(results(indices,2), results(indices,4)./wavePower, 'DisplayName', ...
            sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
    end
end

set(gcf, 'Position', [131         635        1555         627])
copygraphics(gcf, 'Resolution',300)