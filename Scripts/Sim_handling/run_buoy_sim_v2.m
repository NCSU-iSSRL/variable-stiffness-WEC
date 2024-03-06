%clear;clc;
%Simulink.sdi.clear;

% T = 4.5;
% f = 1/T;
% w = f/2/pi;
%buoyMass = 207590; % kg
% k = w^2*buoyMass;
% c = 2*buoyMass*w;

% spring_const = 6e6; % N/m
% w = sqrt(spring_const/buoyMass);
% cCrit = 2*buoyMass*w;
% damping = 0.1*cCrit;
%damping = 300000%1200000; %N/(m/s)
%%spring_const = k;
%damping = 0.1*c;

qCol = 0;
qRow = 0;
powerMatrixMechanical = [];
powerMatrixElectrical = [];
wave_amplitude_sweep = 0.25:0.75:9.75;
%wave_period_sweep = 4.5:1:19.5;
wave_period_sweep = 1.5:1:12.5;

useParallel = true;

%%% sequential
if ~useParallel
    for wave_amplitude = wave_amplitude_sweep
        qRow = qRow + 1;
        qCol = 0;
        for wave_period = wave_period_sweep
            qCol = qCol + 1;
            tsc = sim("buoy_sim_v1.slx", "StopTime", "60");
            [powerMatrixMechanical, powerMatrixElectrical] = updatePowerMatrices(powerMatrixMechanical, powerMatrixElectrical, qRow, qCol, tsc);
        end
    end
end

%%% parallel
if useParallel
    q = 0;
    for qRow = 1:length(wave_amplitude_sweep)
        for qCol = 1:length(wave_period_sweep)
            q = q+1;
            in(q) = Simulink.SimulationInput('buoy_sim_v1');
            in(q) = in(q).setVariable('wave_amplitude', wave_amplitude_sweep(qRow));
            in(q) = in(q).setVariable('wave_period', wave_period_sweep(qCol));
            in(q) = in(q).setVariable('spring_const', spring_const);
            in(q) = in(q).setVariable('damping', damping);
        end
    end
    out = parsim(in);
    
    q = 0;
    for qRow = 1:length(wave_amplitude_sweep)
        for qCol = 1:length(wave_period_sweep)
            q = q+1;
            tsc = out(q);
            [powerMatrixMechanical, powerMatrixElectrical] = updatePowerMatrices(powerMatrixMechanical, powerMatrixElectrical, qRow, qCol, tsc);
        end
    end
end
%% plot
figure(1)
clf
%levels = 0:0.2e7:2e7;
contourf(wave_period_sweep, wave_amplitude_sweep, powerMatrixMechanical)
colorbar()
xlabel('Wave period (s)')
ylabel('Wave amplitude (m)')
title(sprintf('Mechanical power matrix - K = %d N/m, C = %d N/(m/s)', spring_const, damping))

figure(2)
clf
%levels = 0:2e4:5e6;
contourf(wave_period_sweep, wave_amplitude_sweep, powerMatrixElectrical)
colorbar()
xlabel('Wave period (s)')
ylabel('Wave amplitude (m)')
title(sprintf('Electrical power matrix - K = %d N/m, C = %d N/(m/s)', spring_const, damping))

%% functions
function [powerMatrixMechanical, powerMatrixElectrical] = updatePowerMatrices(powerMatrixMechanical, powerMatrixElectrical, qRow, qCol, tsc)
    %damper_power = get(tsc.logsout, 'damper_power');
    %mean_damper_power = damper_power.Values.mean;
    mechanical_energy = get(tsc.logsout, 'mechanical_energy');
    mean_damper_power = mechanical_energy.Values.Data(end)/mechanical_energy.Values.Time(end); % time-averaged power (J/s)
    powerMatrixMechanical(qRow, qCol) = mean_damper_power;

    %electrical_power = get(tsc.logsout, 'electrical_power');
    %mean_electrical_power = electrical_power.Values.mean;
    electrical_energy = get(tsc.logsout, 'electrical_energy');
    mean_electrical_power = electrical_energy.Values.Data(end)/electrical_energy.Values.Time(end); % time-averaged power (J/s)
    powerMatrixElectrical(qRow, qCol) = mean_electrical_power;
end