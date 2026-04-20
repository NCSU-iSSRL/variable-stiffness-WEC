function [avgPower, HP_strain] = func_run_cluster_wecSim(waveHeightIn, wavePeriodIn, gearRatioIn)
waveHeight = waveHeightIn;
wavePeriod = wavePeriodIn;
turbine_gear_ratio = gearRatioIn;
try
    wecSim;
    %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
    avgPower = get(logsout, 'elec_Watt_avg');
    HP_strain = get(logsout, 'HP_strain');
catch ME
    avgPower = nan;
    HP_strain = nan;
end
end