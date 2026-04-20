% given a wave period, find the best regulator setting
clear;clc;
waveHeights = 0.08;
wavePeriods = 2:-0.25:0.75;
%regulator_set_pressure_PSI_in = 0.5:0.25:15;
results = [];

bestRegulatorSetting = 1.5;

for waveHeight = waveHeights
    for wavePeriod = wavePeriods
        numConsequtiveWorseRuns = 0;
        bestAvgPower = 0;
        regulator_set_pressure_PSI_in = bestRegulatorSetting-1:0.125:bestRegulatorSetting+15;
        for regulator_set_pressure_PSI = regulator_set_pressure_PSI_in
            if numConsequtiveWorseRuns <= 5
                results(end+1,:) = [nan nan nan nan];
                try
                    wecSim;
                    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                    avgPower = get(logsout, 'mech_Watt_avg');
                    results(end,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, mean(avgPower.Values.Data(end-50:end))];
                end

                if mean(avgPower.Values.Data(end-50:end)) > bestAvgPower
                    bestAvgPower = mean(avgPower.Values.Data(end-50:end));
                    bestRegulatorSetting = regulator_set_pressure_PSI;
                    numConsequtiveWorseRuns = 0;
                else
                    numConsequtiveWorseRuns = numConsequtiveWorseRuns + 1;
                end
            end
        end
    end
end

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'D:\WEC-Sim\WEC-Sim\Projects\plunger2_buoy\output';
filename = sprintf('%s\\P2_sim_sweep_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results");

%% plot
figure(41)
clf
hold on
grid on
legend()
xlabel('Regulator setting (PSI)')
ylabel('Time-averaged power (W)')
indices = ~isnan(results(:,1));
waveHeights = unique(results(indices,1))';
wavePeriods = unique(results(indices,2))';

for waveHeight = waveHeights
    for wavePeriod = wavePeriods
        indices = results(:,1) == waveHeight & results(:,2) == wavePeriod;
        plot(results(indices,3), results(indices,4), 'DisplayName', ...
            sprintf('Wave height = %.2f, Wave period = %.2f', waveHeight, wavePeriod));
    end
end