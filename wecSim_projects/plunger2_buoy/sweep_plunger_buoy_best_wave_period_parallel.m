% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.1;
wavePeriods = 1.7:-0.1/2:0.9;
regulator_set_pressure_PSI_in = 10%1:2:15;

fid = fopen('wecSimInputFile.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

c = parcluster;
j = createJob(c, 'AdditionalPaths', "Z:\NCSU_Desktop\WEC-Sim\source", ...
    'AttachedFiles', ["C:\Users\Carson\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\wecSim_projects\plunger2_buoy", ...
    "C:\Users\Carson\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\Source"], ...
    'AutoAddClientPath', true);

for waveHeight = waveHeights
    for wavePeriod = wavePeriods
        for regulator_set_pressure_PSI = regulator_set_pressure_PSI_in
            createTask(j, @func_run_plunger_sim, 1, {waveHeight, wavePeriod, regulator_set_pressure_PSI});
        end
    end
end

submit(j);
wait(j);
results = [];
for q = 1:length(j.Tasks)
    try
        results(end+1,:) = [j.Tasks(q, 1).OutputArguments{1}];
    end
end

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\P2_sim_sweep_regulator_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "wecSimInputScript", "runTimeStamp");

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