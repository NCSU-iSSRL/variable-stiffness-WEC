% given a regulator setting, find the best wave period
clear all;clc;

% From historical data (USA CDIP buoys), the Pareto-like frontier defining
%   typical max. wave height vs. wave period follows an approximately linear
%   form as H = 1.2032*T - 2.2521
%   or quadratic form as H = 0.1023*T^2 + 0.0318*T + 0.0501
% So, any wave conditions above this line (wave height above line for a
%   given wave period) need not be simulated.
% See C:\Users\cmmcguir\OneDrive - North Carolina State
%   University\iSSRL\Research\variable-stiffness-WEC\Source\Scripts\find_wave_period_height_Pareto.m
%
% The NREL Marine Energy Atlas specifies simulation matrices with bins:
%   Sig. wave height: 0.25m to 9.75m center values with 0.5m bins
%   Energy period: 0.5s to 20.5s center values with 1s bins

waveHeights = linspace(0.1, 8, 12);
wavePeriods = linspace(1.75, 10, 12);
% waveHeights = 0.25:0.5:9.75; % NREL
% wavePeriods = 0.5:1:20.5; % NREL
%waveHeights = 2;
%wavePeriods = 6;
gear_ratio_in = 11;
powerMatrix = nan(length(waveHeights), length(wavePeriods), length(gear_ratio_in));
results = [];
simData = {};

simSweep = 1; % flag used in wecSimInputFile

fid = fopen('wecSimInputFile_p3_1m_TG.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

%%% runs sims one-by-one
for gearRatioQ = 1:length(gear_ratio_in)
    for waveHeightQ = 1:length(waveHeights)
        for wavePeriodQ = 1:length(wavePeriods)
            waveHeight = waveHeights(waveHeightQ);
            wavePeriod = wavePeriods(wavePeriodQ);
            turbine_gear_ratio = gear_ratio_in(gearRatioQ);
            results(end+1,:) = [waveHeight, wavePeriod, turbine_gear_ratio, nan, nan];
            if waveHeight <= 0.1023*wavePeriod.^2 + 0.0318*wavePeriod + 0.0501 + 0.25 % restrict sim domain to fall within typical wave conditions at CDIP buoys
                try
                    wecSim;
                    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                    avgPower = get(logsout, 'elec_Watt_avg');
                    HP_strain = get(logsout, 'HP_strain');
                    results(end,4:5) = [mean(avgPower.Values.Data(end-1000:end)), max(HP_strain.Values.Data(end-1000:end))];
                    simData{end+1}.wavePeriod = wavePeriod;
                    simData{end}.waveHeight = waveHeight;
                    simData{end}.turbine_gear_ratio = turbine_gear_ratio;
                    simData{end}.signalLogs = logsout;
                    powerMatrix(waveHeightQ, wavePeriodQ, gearRatioQ) = mean(avgPower.Values.Data(end-1000:end));
                end
            end
        end
    end
end

%%% runs sims with parallel compute toolbox via wecSimPCT.m
% for gearRatioQ = 1:length(gear_ratio_in)
%     waveHeight = waveHeights(1:2);
%     wavePeriod = wavePeriods(1:2);
%     turbine_gear_ratio = gear_ratio_in(gearRatioQ);
%     wecSimPCT; % issues when running with nonlinearhydro = 2
% end 

simSweep = 0; % flag used in wecSimInputFile

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\P3_1m_TG_sim_sweep_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "powerMatrix", "waveHeights", "wavePeriods", "gear_ratio_in", "PTO_capacity_W", "wecSimInputScript", "runTimeStamp");

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
    filename = sprintf('%s\\P3_1m_TG_sim_sweep_full_%s.mat', dataSaveFolder, runTimeStamp);
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
    for gearRatio = gear_ratio_in
        indices = results(:,1) == waveHeight & results(:,3) == gearRatio;
        subplot(1,2,1)
        plot(results(indices,2), results(indices,4), 'DisplayName', ...
            sprintf('Wave height = %.2f m, Gear ratio = %.2f', waveHeight, gearRatio));
        
        charLength = 1; % characteristic length for wave pow eqn, lower cylinder diameter
        wavePower = 1000*9.81^2/64/pi * waveHeight^2 * results(indices,2) * charLength;
        subplot(1,2,2)
        plot(results(indices,2), results(indices,4)./wavePower, 'DisplayName', ...
            sprintf('Wave height = %.2f m, Gear ratio = %.2f', waveHeight, gearRatio));
    end
end

linkaxes([ax1 ax2], 'x')
set(gcf, 'Position', [131         635        1555         627])
for q = 1:3
    fontsize('increase')
end
% copygraphics(gcf, 'Resolution',300)

%% contour plots

% look for best impedance choice
bestImpedanceChoice = nan .* powerMatrix(:,:,1);
for heightQ = 1:length(waveHeights)
    for periodQ = 1:length(wavePeriods)
    [~, bestImpedanceChoice(heightQ, periodQ)] = max(powerMatrix(heightQ, periodQ, :));
    end
end

bestImpedanceChoice = gear_ratio_in(bestImpedanceChoice);

figNum = 11;
cBarMaxPower = 600;
for gearRatio = gear_ratio_in
    indices = results(:,3) == gearRatio;
    gearRatioQ = find(gear_ratio_in == gearRatio);
    figure(figNum)
    clf

    contourf(wavePeriods, waveHeights, powerMatrix(:,:,gearRatioQ), 20)
    xlabel('Wave period (s)')
    ylabel('Wave height (m)')
    c = colorbar;
    c.Label.String = 'Time avg. power (W)';
    clim([0 cBarMaxPower])
    title(sprintf('Gear ratio = %.2f', gearRatio))

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
contourf(wavePeriods, waveHeights, bestImpedanceChoice, length(gear_ratio_in) -1)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = 'Best choice gear ratio, G';

subplot(2,2,3)
percentImprovMin = (max(powerMatrix, [], 3) - powerMatrix(:,:,1)) ./ powerMatrix(:,:,1) .* 100;
percentImprovMin(percentImprovMin > 200) = 200;
contourf(wavePeriods, waveHeights, percentImprovMin)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = '% improvement over lowest static G';
clim([0 200])

subplot(2,2,4)
percentImprovMax = (max(powerMatrix, [], 3) - powerMatrix(:,:,end)) ./ powerMatrix(:,:,end) .* 100;
percentImprovMax(percentImprovMax > 200) = 200;
contourf(wavePeriods, waveHeights, percentImprovMax)
xlabel('Wave period (s)')
ylabel('Wave height (m)')
c = colorbar;
c.Label.String = '% improvement over highest static G';
clim([0 200])

sgtitle('Power comparison contours')