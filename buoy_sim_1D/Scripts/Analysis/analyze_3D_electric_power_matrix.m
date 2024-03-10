clear;clc;
files = dir('data\*.mat');
%files = dir('C:\Users\Carson\OneDrive - North Carolina State University\iSSRL\Research\CSI WEC\WEC_Sim_data\stiffness_damping_wavePeriod_waveHeight_sweep\*.mat');
load(files(end).name)
powerMatrixElectrical_3D = simSweepResults.matrix;

[r, c, d] = size(powerMatrixElectrical_3D); % row - amplitude, col - period, depth - stiffness
maxElectricalPowerMatrix = [];
bestStiffness = [];
for r = 1:r
    for c = 1:c
        powerVals = abs(reshape(powerMatrixElectrical_3D(r,c,:), [1 d]));
        [maxPower, ind] = max(powerVals);
        maxElectricalPowerMatrix(r,c) = maxPower;
        bestStiffness(r,c) = simSweepResults.springConstSweep(ind);
    end
end

%% plot
wave_amplitude_sweep = simSweepResults.waveAmplitudeSweep;
wave_period_sweep = simSweepResults.wavePeriodSweep;
figure(31)
clf
%levels = linspace(0, max(max(maxElectricalPowerMatrix))./1000, 15);
%levels = linspace(0, max(max(abs(simSweepResults.matrix(:,:,ind))))./1000, 15);\
levels = linspace(0, 400, 10);
subplot(1,3,1)
spring_const_des = 97e3;
ind = find(simSweepResults.springConstSweep == spring_const_des);
if isempty(ind)
    ind = 1;
    spring_const_des = simSweepResults.springConstSweep(ind);
end
contourf(wave_period_sweep, 2*wave_amplitude_sweep, abs(simSweepResults.matrix(:,:,ind))./1000, levels)
clim([min(levels) 1*max(levels)])
colorbar()
xlabel('Wave period (s)')
ylabel('Wave height (m)')
%title(sprintf('Electrical power matrix, K = %d N/m', spring_const_des))
title('(a)')
%xlim([4.5 10])
%ylim([0.25 5])

subplot(1,3,2)
contourf(wave_period_sweep, 2*wave_amplitude_sweep, maxElectricalPowerMatrix./1000, levels)
clim([min(levels) 1*max(levels)])
colorbar()
xlabel('Wave period (s)')
ylabel('Wave height (m)')
%title('Electrical power matrix, variable-K')
title('(b)')
%xlim([4.5 10])
%ylim([0.25 5])


% spring_const = 0.1e6;
% buoyMass = 207590/10/10/10; % kg
% w = sqrt((spring_const+3e6)/buoyMass);
% cCrit = 2*buoyMass*w;
% damping = 0.1*cCrit;
% %damping = simSweepResults.damping;
% run_buoy_sim_v2
percentDiff = (maxElectricalPowerMatrix - abs(simSweepResults.matrix(:,:,ind))) ./ abs(0.5.*(abs(simSweepResults.matrix(:,:,ind)) + maxElectricalPowerMatrix));
% %%
% figure(32)
% clf
subplot(1,3,3)
contourf(wave_period_sweep, 2*wave_amplitude_sweep, percentDiff*100)%, 'LineColor', 'none')
c = colorbar();
c.Ruler.TickLabelFormat='%g%%';
xlabel('Wave period (s)')
ylabel('Wave height (m)')
title('(c)')
%title('% improvement with variable-K system')
%clim([0 3])
%ylim([0.25 5])

set(gcf, "Position", [0 100 1756 499])
fontsize(scale=2)

%%
% figure(33)
% clf
% hold on
% [row,col] = size(bestStiffness);
% buoyMass = 207590; % kg
% for q = 1:row
%     naturalFreq = sqrt(bestStiffness(q,:) / buoyMass);
%     naturalPeriod = 1./(naturalFreq*2*pi);
%     naturalPeriod(isinf(naturalPeriod)) = 0;
%     plot(wave_period_sweep, naturalPeriod)
% end

figure(34)
clf
contourf(wave_period_sweep, wave_amplitude_sweep, bestStiffness)

colorbar()
xlabel('Wave period (s)')
ylabel('Wave amplitude (m)')
title('Best stiffness')