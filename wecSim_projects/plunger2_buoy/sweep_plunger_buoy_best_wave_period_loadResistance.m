% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.08;
%wavePeriods = 2:-0.25:0.75;
R_load_in = 2:2:6;
results = [];
simData = {};

bestWavePeriod = 1.75;

for waveHeight = waveHeights
    for R_load = R_load_in
        numConsequtiveWorseRuns = 0;
        bestAvgPower = 0;
        wavePeriods = bestWavePeriod+0.25:-0.125:0.75;
        for wavePeriod = wavePeriods
            if numConsequtiveWorseRuns < 4
                results(end+1,:) = [nan nan nan nan nan];
                try
                    wecSim;
                    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                    avgPower = get(logsout, 'mech_Watt_avg');
                    FAM_stretch = get(logsout, 'FAM_stretch');
                    results(end,:) = [waveHeight, wavePeriod, R_load, mean(avgPower.Values.Data(end-50:end)), max(FAM_stretch.Values.Data(end-50:end))];
                    simData{end+1}.wavePeriod = wavePeriod;
                    simData{end}.waveHeight = waveHeight;
                    simData{end}.signalLogs = logsout;
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
filename = sprintf('%s\\P2_sim_sweep_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "simData");

%% plot

figure(42)
clf
hold on
grid on
legend()
xlabel('Wave period (s)')
ylabel('Time-averaged power (W)')

figure(43)
clf
hold on
grid on
legend()
xlabel('Wave period (s)')
ylabel('Non-dimensionalized power (P_{WEC}/P_{WAVE})')

indices = ~isnan(results(:,1));
waveHeights = unique(results(indices,1))';
load_resistances = unique(results(indices,3))';

for waveHeight = waveHeights
    for R_load = load_resistances
        indices = results(:,1) == waveHeight & results(:,3) == R_load;
        figure(42)
        plot(results(indices,2), results(indices,4), 'DisplayName', ...
            sprintf('Wave height = %.2f m, G = %.2f', waveHeight, R_load));
        
        charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
        wavePower = 1000*9.81^2/64/pi * waveHeight^2 * results(indices,2) * charLength;
        figure(43)
        plot(results(indices,2), results(indices,4)./wavePower, 'DisplayName', ...
            sprintf('Wave height = %.2f m, G = %.2f', waveHeight, R_load));
    end
end