function [capacityFactors, buoyUptimeRatio] = historical_wave_timeseries_sim_calc(simDataFile, historicalDataFile, persistentLoad, manualHydImpedance, drawPlots)

%drawPlots = 0;

%simDataFile = "C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\wecSim_projects\ONR\p3_1m\results\P3_1m_sim_sweep_resultsOnly_2025_07_24_17_55_52.mat";
%historicalDataFile = "E:\CDIP_buoy_data\192p1_historic.nc";
%historicalDataFile = "Z:\NCSU_Desktop\Research Data\cdip_buoy_data\192p1_historic.nc";

load(simDataFile)

if ~exist("PTO_capacity_W", 'var') % early sim runs did not save this variable, check that the value is correct from "wecSimInputScript" var
    PTO_capacity_W = 1000;
    disp('Ensure that PTO_capacity_W is set to the correct value.')
end

if exist("regulator_set_pressure_PSI_in", 'var')
    pto_setting = regulator_set_pressure_PSI_in;
elseif exist("gear_ratio_in", 'var')
    pto_setting = gear_ratio_in;
end

time = ncread(historicalDataFile, 'waveTime'); % seconds since epoch
sigWaveHeight = ncread(historicalDataFile, 'waveHs'); % m
waveAvgPeriod = ncread(historicalDataFile, 'waveTa'); % s

% outliers = isoutlier(sigWaveHeight) | isoutlier(waveAvgPeriod);
% sigWaveHeight = sigWaveHeight(~outliers);
% waveAvgPeriod = waveAvgPeriod(~outliers);
% time = time(~outliers);

time_dt = datetime(time, 'ConvertFrom', 'epochtime');

% look for best impedance choice
bestImpedanceChoice = nan .* powerMatrix(:,:,1);
for heightQ = 1:length(waveHeights)
    for periodQ = 1:length(wavePeriods)
    [~, bestImpedanceChoice(heightQ, periodQ)] = max(powerMatrix(heightQ, periodQ, :));
    end
end

bestImpedanceChoice = pto_setting(bestImpedanceChoice);

maxPowerMatrix = max(powerMatrix, [], 3);

% calc instant power trace for each regulator/ACV set cracking pressure
instantPowerTraces = nan(1, length(time_dt), length(pto_setting));
capacityFactorResults = nan(length(pto_setting)+1, 3);


for q = 1:length(pto_setting)
    powerTrace = interp2(wavePeriods, waveHeights, powerMatrix(:,:,q), waveAvgPeriod, sigWaveHeight);
    instantPowerTraces(1,:,q) = powerTrace;
    %plot(time_dt, instantPowerTraces(1,:,q), 'DisplayName', sprintf('ACV - %.1f PSI', pto_setting(q)))

    capacityFactor = mean(powerTrace(~isnan(powerTrace))) / PTO_capacity_W;
    capacityFactorResults(q,:) = [pto_setting(q), capacityFactor, capacityFactor * PTO_capacity_W];
end
[~, bestStaticImpedanceChoiceInd] = max(capacityFactorResults(:,2));

% calc instant power trace from maxPowerMatrix and interpolate hydraulic
%   impedance settings
maxPowerTrace = interp2(wavePeriods, waveHeights, maxPowerMatrix, waveAvgPeriod, sigWaveHeight);

maxCapacityFactor = mean(maxPowerTrace(~isnan(maxPowerTrace))) / PTO_capacity_W;
capacityFactorResults(end,:) = [999, maxCapacityFactor, maxCapacityFactor * PTO_capacity_W];

bestImpedanceTrace = interp2(wavePeriods, waveHeights, bestImpedanceChoice, waveAvgPeriod, sigWaveHeight);

%%% battery charge history simulation
powerConversionEfficiency = 1;
manualHydImpedanceInd = find(manualHydImpedance == pto_setting);
powerHist = powerConversionEfficiency * [instantPowerTraces(:,:,manualHydImpedanceInd)', ...
    instantPowerTraces(:,:,bestStaticImpedanceChoiceInd)', maxPowerTrace];

batteryMaxCharge = 1630 * 3600; % W-hr --> J
batteryChargeHist = nan(length(powerHist), 3);
batteryChargeHist(1,:) = batteryMaxCharge;

% persistentLoad = 70; % W

for q = 2:length(powerHist)
    
    dt_step = seconds(time_dt(q) - time_dt(q-1));
    dt_step(dt_step > 3600*24) = 0; % data missing for more than one day, do not drain battery

    if isnan(powerHist(q,1))
        batteryCharge = batteryChargeHist(q-1, :) - persistentLoad*dt_step;
    else
        batteryCharge = batteryChargeHist(q-1, :) + (powerHist(q, :) - persistentLoad)*dt_step;
    end

    batteryChargeHist(q, :) = max(min(batteryCharge, batteryMaxCharge*[1 1 1]), [0 0 0]);

    % if isnan(powerHist(q,1)) && batteryChargeHist(q , 1) > batteryChargeHist(q-1, 1)
    %     a = 1;
    % end
end

if drawPlots
    figure(1)
    clf
    ax11 = subplot(4,1,1);
    yyaxis left
    plot(time_dt, sigWaveHeight)
    grid on
    ylabel('H_s (m)')
    %title('CDIP Station 192', 'Interpreter','none')
    
    %ax2 = subplot(4,1,2);
    yyaxis right
    plot(time_dt, waveAvgPeriod)
    grid on
    ylabel('T_a (s)')
    set(gca,'xticklabel',[])
    
    ax12 = subplot(4,1,2);
    hold on
    ylabel('Hyd. power (W)')
    legend()
    RGB = orderedcolors("gem");
    %plot(time_dt, instantPowerTraces(1,:,bestStaticImpedanceChoiceInd), 'DisplayName', 'Best Static Impedance Setting', 'Color', RGB(3,:))
    %plot(time_dt, maxPowerTrace, 'DisplayName', 'Adaptive Stiffness', 'Color', RGB(4,:))
    plot(time_dt, powerHist(:,2), 'DisplayName', 'Best Static Impedance Setting', 'Color', RGB(3,:))
    plot(time_dt, powerHist(:,3), 'DisplayName', 'Adaptive Stiffness', 'Color', RGB(4,:))
    set(gca,'xticklabel',[])
    
    ax13 = subplot(4,1,3);
    plot(time_dt, ones(length(time_dt), 1) * pto_setting(bestStaticImpedanceChoiceInd), 'DisplayName', 'Best Static Impedance Setting', 'Color', RGB(3,:))
    hold on
    plot(time_dt, bestImpedanceTrace, 'DisplayName', 'Adaptive Stiffness', 'Color', RGB(4,:))
    set(gca,'xticklabel',[])
    ylabel('Impedance (PSI)')
    
    ax14 = subplot(4,1,4);
    plot(time_dt, batteryChargeHist(:,2) / batteryMaxCharge * 100, 'DisplayName', 'Best Static Turbine Setting', 'Color', RGB(3,:))
    hold on
    plot(time_dt, batteryChargeHist(:,3) / batteryMaxCharge * 100, 'DisplayName', 'Adaptive Stiffness', 'Color', RGB(4,:))
    ylabel('Charge (%)')
    
    linkaxes([ax11 ax12 ax13 ax14], 'x')
    dl = datetime('01-Jan-2018');
    dr = datetime('31-Dec-2018');
    %xlim([dl dr])
    set(figure(1), 'Position', [1100 400 930 665])
    
    for q = 1:4
        fontsize('increase')
    end

    copygraphics(figure(1), "Resolution", 300)
end

buoyUptimeRatio = sum(batteryChargeHist > 0) / length(batteryChargeHist); % [non adaptive, adaptive]

capacityFactors = capacityFactorResults([manualHydImpedanceInd, bestStaticImpedanceChoiceInd, length(capacityFactorResults)], :);