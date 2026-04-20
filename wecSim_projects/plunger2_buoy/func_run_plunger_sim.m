function results = func_run_plunger_sim(waveHeight_in, wavePeriod_in, regulator_set_pressure_PSI_in)
    waveHeight = waveHeight_in;
    wavePeriod = wavePeriod_in;
    regulator_set_pressure_PSI = regulator_set_pressure_PSI_in;
    avgPower = -1;
    simSweep = 1;
    wecSim
    % avgPowerTs = get(logsout, 'mech_Watt_avg');
    % avgPower = mean(avgPowerTs.Values.Data(end-50:end));\
    avgPower = get(logsout, 'mech_Watt_avg');
    FAM_stretch = get(logsout, 'FAM_stretch');
    results = [waveHeight, wavePeriod, regulator_set_pressure_PSI, mean(avgPower.Values.Data(end-1000:end)), max(FAM_stretch.Values.Data(end-1000:end))];
end