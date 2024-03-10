clear;clc;
startFolder = "buoy_simulation_v2"; % change this to set your starting folder
folder = strsplit(cd, '\');
if folder{end} ~= startFolder
    disp('Incorrect path. Move to ''CSI WEC\buoy_simulation'' folder')
    return
end
runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');

powerMatrixElectrical_3D = [];
qPM3d = 0;

saveFigures = 0;
saveSimData = 1;

damping = 300e3;
spring_const_sweep = [2.4e3 97e3 270e3 560e3 1e6]
for spring_const_in = spring_const_sweep
    spring_const = spring_const_in;
    % buoyMass = 207590; % kg
    % w = sqrt(spring_const/buoyMass);
    % cCrit = 2*buoyMass*w;
    %damping = 0.1*cCrit;

    run_buoy_sim_v3
    
    if saveFigures
        figure(1)
        savefig(sprintf('figures\\contours\\mechanicalPower_damping_%d_springConst_%d_%s.fig', damping, spring_const, runTimeStamp))
    
        figure(2)
        savefig(sprintf('figures\\contours\\electricalPower_damping_%d_springConst_%d_%s.fig', damping, spring_const, runTimeStamp))
    end
    close all

    qPM3d = qPM3d + 1;
    powerMatrixElectrical_3D(:,:,qPM3d) = powerMatrixElectrical;
end
simSweepResults.matrix = powerMatrixElectrical_3D;
simSweepResults.springConstSweep = spring_const_sweep;
simSweepResults.damping = damping;
simSweepResults.waveAmplitudeSweep = wave_amplitude_sweep;
simSweepResults.wavePeriodSweep = wave_period_sweep;
if saveSimData
    save([pwd, sprintf('\\data\\electricalPowerMatrix_3D_%s.mat', runTimeStamp)], "simSweepResults")
end