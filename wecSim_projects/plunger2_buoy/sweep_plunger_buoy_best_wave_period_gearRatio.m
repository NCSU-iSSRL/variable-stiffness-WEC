% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.08;
%wavePeriods = 2:-0.25:0.75;
gear_ratio_in = 1:0.5:3;
results = [];
simData = {};

bestWavePeriod = 1.75;
simSweep = 1; % flag used in wecSimInputFile

for waveHeight = waveHeights
    for G = gear_ratio_in
        numConsequtiveWorseRuns = 0;
        bestAvgPower = 0;
        wavePeriods = bestWavePeriod+0.25:-0.125/2:0.75;
        for wavePeriod = wavePeriods
            if numConsequtiveWorseRuns < 5
                results(end+1,:) = [nan nan nan nan nan];
                try
                    wecSim;
                    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                    avgPower = get(logsout, 'mech_Watt_avg');
                    FAM_stretch = get(logsout, 'FAM_stretch');
                    results(end,:) = [waveHeight, wavePeriod, G, mean(avgPower.Values.Data(end-1000:end)), max(FAM_stretch.Values.Data(end-1000:end))];
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

simSweep = 0;

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\P2_sim_sweep_gearRatio_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results");

% save all sim output data (large files, do not put on cloud storage)
saveLargeData = 1;
switch getenv('COMPUTERNAME')
    case "VERMILLIONLAB13"
        dataSaveFolder = 'C:\Users\cmmcguir\Documents\research_data\WEC_sim_data\plunger2_buoy';
    case "DESKTOP-8E6TRFQ"
        dataSaveFolder = 'S:\NCSU_NAS\Research_Data\Adaptive WEC\WEC_sim_full_data\plunger2_buoy';
    otherwise
        % add other computers here
        disp('!!! No large data save folder specified !!!')
        saveLargeData = 0;
end

if saveLargeData
    filename = sprintf('%s\\P2_sim_sweep_gearRatio_full_%s.mat', dataSaveFolder, runTimeStamp);
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
ylabel('Time-averaged power (W)')

%figure(43)
%clf
subplot(1,2,2)
hold on
grid on
legend()
xlabel('Normalized wave period (T_{wave}/T_{N})')
ylabel('Normalized power (P_{WEC}/P_{wave})')

indices = ~isnan(results(:,1));
waveHeights = unique(results(indices,1))';
gearRatios = unique(results(indices,3))';

for waveHeight = waveHeights
    for G = gearRatios
        indices = results(:,1) == waveHeight & results(:,3) == G;
        subplot(1,2,1)
        plot(results(indices,2), results(indices,4), 'DisplayName', ...
            sprintf('Wave height = %.2f m, G = %.2f', waveHeight, G));
        
        charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
        wavePower = 1000*9.81^2/64/pi * waveHeight^2 * results(indices,2) * charLength;
        Tnat = 1.69; % sec, natural period of buoy + hose-pump (elastic only, no pressure-dependent force)
        subplot(1,2,2)
        plot(results(indices,2)/Tnat, results(indices,4)./wavePower, 'DisplayName', ...
            sprintf('Wave height = %.2f m, G = %.2f', waveHeight, G));
    end
end

for q = 1:3
    fontsize('increase')
end

% legend('G = 1', 'G = 1.5', 'G = 2', 'G = 2.5', 'G = 3')