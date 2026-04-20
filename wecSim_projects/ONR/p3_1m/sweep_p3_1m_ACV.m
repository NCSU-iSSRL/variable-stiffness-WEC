% given a regulator setting, find the best wave period
clear;clc;
%waveHeights = 0.25:0.5:3.25;
waveHeights = linspace(0.25, 3.5, 10);
%wavePeriods = 2:0.5:8;
wavePeriods = linspace(2.5, 10, 10);
regulator_set_pressure_PSI_in = 9;
%regulator_set_pressure_PSI_in = 9;
%regulator_set_pressure_PSI_in = 10:5:50;
powerMatrix = nan(length(waveHeights), length(wavePeriods), length(regulator_set_pressure_PSI_in));
results = [];
simData = {};

simSweep = 1; % flag used in wecSimInputFile

fid = fopen('wecSimInputFile_p3_1m_ACV.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

for regulatorQ = 1:length(regulator_set_pressure_PSI_in)
    for waveHeightQ = 1:length(waveHeights)
        for wavePeriodQ = 1:length(wavePeriods)
            waveHeight = waveHeights(waveHeightQ);
            wavePeriod = wavePeriods(wavePeriodQ);
            regulator_set_pressure_PSI = regulator_set_pressure_PSI_in(regulatorQ);
            results(end+1,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, nan, nan];
            try
                wecSim;
                %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                avgPower = get(logsout, 'mech_Watt_avg');
                HP_strain = get(logsout, 'HP_strain');
                results(end,4:5) = [mean(avgPower.Values.Data(end-1000:end)), max(HP_strain.Values.Data(end-1000:end))];
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
filename = sprintf('%s\\P3_1m_ACV_sim_sweep_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "powerMatrix", "waveHeights", "wavePeriods", "regulator_set_pressure_PSI_in", "PTO_capacity_W", "wecSimInputScript", "runTimeStamp");

% save all sim output data (large files, do not put on cloud storage)
saveLargeData = 1;
switch getenv('COMPUTERNAME')
    case {"VERMILLIONLAB13", "MAE-DT-001"}
        dataSaveFolder = 'E:\WEC_sim_data\plunger3_buoy_1m';
    otherwise
        % add other computers here
        disp('!!! No large data save folder specified !!!')
        saveLargeData = 0;
end

if saveLargeData
    filename = sprintf('%s\\P3_1m_ACV_sim_sweep_full_%s.mat', dataSaveFolder, runTimeStamp);
    save(filename, "results", "simData", '-v7.3');
end

%% plot

figure(42)
clf
ax1 = subplot(1,2,1);
hold on
grid on
%legend()
xlabel('Wave period (s)')
ylabel('Time-averaged power (W)')
%ylim([50 500])


ax2 = subplot(1,2,2);
hold on
grid on
legend()
xlabel('Wave period (s)')
ylabel('Non-dimensionalized power (P_{WEC}/P_{WAVE})')
%ylim([0 0.35])

%sgtitle(sprintf('H0 = %.2f m -- %s', waveHeights, runTimeStamp), 'Interpreter','none')

for waveHeight = waveHeights
    for regulatorSetting = regulator_set_pressure_PSI_in
        indices = results(:,1) == waveHeight & results(:,3) == regulatorSetting;
        subplot(1,2,1)
        plot(results(indices,2), results(indices,4), 'DisplayName', ...
            sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
        
        charLength = 1; % characteristic length for wave pow eqn, lower cylinder diameter
        wavePower = 1000*9.81^2/64/pi * waveHeight^2 * results(indices,2) * charLength;
        subplot(1,2,2)
        plot(results(indices,2), results(indices,4)./wavePower, 'DisplayName', ...
            sprintf('Wave height = %.2f m, Regulator setting = %.2f PSI', waveHeight, regulatorSetting));
    end
end

linkaxes([ax1 ax2], 'x')
set(gcf, 'Position', [131         635        1555         627])
for q = 1:3
    fontsize('increase')
end
copygraphics(gcf, 'Resolution',300)

%% contour plots

% look for best impedance choice
bestImpedanceChoice = nan .* powerMatrix(:,:,1);
for heightQ = 1:length(waveHeights)
    for periodQ = 1:length(wavePeriods)
    [~, bestImpedanceChoice(heightQ, periodQ)] = max(powerMatrix(heightQ, periodQ, :));
    end
end

bestImpedanceChoice = regulator_set_pressure_PSI_in(bestImpedanceChoice);

figNum = 11;
cBarMaxPower = 400;
for regulatorSetting = regulator_set_pressure_PSI_in
    indices = results(:,3) == regulatorSetting;
    regulatorQ = find(regulator_set_pressure_PSI_in == regulatorSetting);
    figure(figNum)
    clf

    contourf(wavePeriods, waveHeights, powerMatrix(:,:,regulatorQ), 20)
    xlabel('Wave period (s)')
    ylabel('Wave height (m)')
    c = colorbar;
    c.Label.String = 'Time avg. power (W)';
    clim([0 cBarMaxPower])
    title(sprintf('Regulator setting = %.2f PSI', regulatorSetting))

    figNum = figNum + 1;
end



figure(6)
clf
subplot(2,2,1)
contourf(wavePeriods, waveHeights, max(powerMatrix, [], 3), 20)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = 'Max. time avg. power over all ACV settings (W)';
clim([0 cBarMaxPower])

subplot(2,2,2)
contourf(wavePeriods, waveHeights, bestImpedanceChoice, length(regulator_set_pressure_PSI_in) -1)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = 'Best choice ACV cracking pressure (PSI)';

subplot(2,2,3)
percentImprovMin = (max(powerMatrix, [], 3) - powerMatrix(:,:,1)) ./ powerMatrix(:,:,1) .* 100;
percentImprovMin(percentImprovMin > 200) = 200;
contourf(wavePeriods, waveHeights, percentImprovMin)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = '% improvement over lowest static ACV setting';
clim([0 200])

subplot(2,2,4)
percentImprovMax = (max(powerMatrix, [], 3) - powerMatrix(:,:,end)) ./ powerMatrix(:,:,end) .* 100;
percentImprovMax(percentImprovMax > 200) = 200;
contourf(wavePeriods, waveHeights, percentImprovMax)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = '% improvement over highest static ACV setting';
clim([0 200])

sgtitle('Power comparison contours')