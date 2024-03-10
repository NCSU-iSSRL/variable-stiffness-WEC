clear;clc;
load jointProbabilityDistribution_CapeHatteras_250.mat

ratedPower = 400; % kw

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

spring_const_des = 97e3;
ind = find(simSweepResults.springConstSweep == spring_const_des);
if isempty(ind)
    ind = 1;
    spring_const_des = simSweepResults.springConstSweep(ind);
end
powerMatrixSingleStiff = abs(simSweepResults.matrix(:,:,ind))./1000;
powerMatrixSingleStiff(powerMatrixSingleStiff>ratedPower) = ratedPower;

maxElectricalPowerMatrix = maxElectricalPowerMatrix./1000;
maxElectricalPowerMatrix(maxElectricalPowerMatrix>ratedPower) = ratedPower;

% capacityFactor_singleStiff = sum(sum(powerMatrixSingleStiff.*JPD)) / ratedPower
% capacityFactor_adaptStiff = sum(sum(maxElectricalPowerMatrix.*JPD)) / ratedPower

JPD = JPD_250.sampleMatrix./JPD_250.numSamples; % convert from samples to probability

[rJPD, cJPD] = size(JPD);
averagePower_singleStiff = [];
averagePower_adaptStiff = [];
wave_amplitude_sweep = simSweepResults.waveAmplitudeSweep;
wave_period_sweep = simSweepResults.wavePeriodSweep;

for r = 1:rJPD
    for c = 1:cJPD
        waveHeight = mean(JPD_250.waveHeightRanges_m(r,:));
        wavePeriod = JPD_250.peakPeriod_cols(c);
        
        averagePower_singleStiff(r,c) = interp2(wave_period_sweep, 2*wave_amplitude_sweep, powerMatrixSingleStiff, wavePeriod, waveHeight) * JPD(r,c);
        averagePower_adaptStiff(r,c) = interp2(wave_period_sweep, 2*wave_amplitude_sweep, maxElectricalPowerMatrix, wavePeriod, waveHeight) * JPD(r,c);
    end
end

averagePower_singleStiff(isnan(averagePower_singleStiff)) = 0;
averagePower_adaptStiff(isnan(averagePower_adaptStiff)) = 0;

capacityFactor_singleStiff = sum(sum(averagePower_singleStiff)) / ratedPower
capacityFactor_adaptStiff = sum(sum(averagePower_adaptStiff)) / ratedPower