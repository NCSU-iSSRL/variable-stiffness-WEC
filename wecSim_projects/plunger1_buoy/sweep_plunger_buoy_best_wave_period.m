% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.08;
%wavePeriods = 2:-0.25:0.75;
regulator_set_pressure_PSI_in = 4;%[1 2.5 5 7.5 10 15];
results = [];

bestWavePeriod = 1.25;

for waveHeight = waveHeights
    for regulator_set_pressure_PSI = regulator_set_pressure_PSI_in
        numConsequtiveWorseRuns = 0;
        bestAvgPower = 0;
        wavePeriods = bestWavePeriod+0.25:-0.125/2:0.75;
        for wavePeriod = wavePeriods
            if numConsequtiveWorseRuns < 4
                results(end+1,:) = [nan nan nan nan];
                try
                    wecSim;
                    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                    avgPower = get(logsout, 'mech_Watt_avg');
                    results(end,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, mean(avgPower.Values.Data(end-50:end))];
                end

                if mean(avgPower.Values.Data(end-50:end)) > bestAvgPower
                    bestAvgPower = mean(avgPower.Values.Data(end-50:end));
                    %bestWavePeriod = wavePeriod;
                    numConsequtiveWorseRuns = 0;
                else
                    numConsequtiveWorseRuns = numConsequtiveWorseRuns + 1;
                end
            end
        end
    end
end

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\P1_sim_sweep_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results");

%% plot

figure(42)
clf
hold on
grid on
legend()
xlabel('Wave period (s)')
ylabel('Time-averaged power (W)')
indices = ~isnan(results(:,1));
waveHeights = unique(results(indices,1))';
regulatorSettings = unique(results(indices,3))';

for waveHeight = waveHeights
    for regulatorSetting = regulatorSettings
        indices = results(:,1) == waveHeight & results(:,3) == regulatorSetting;
        plot(results(indices,2), results(indices,4), 'DisplayName', ...
            sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
    end
end