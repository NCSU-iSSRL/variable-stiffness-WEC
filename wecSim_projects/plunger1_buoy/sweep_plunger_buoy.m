clear;clc;
waveHeights = 0.08;
wavePeriods = 0.75:0.25:2;
results = [];


for waveHeight = waveHeights
    for wavePeriod = wavePeriods
        for regulator_set_pressure_PSI = 0.5:0.5:8
            results(end+1,:) = [nan nan nan nan];
            try
                wecSim;
                %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                avgPower = get(logsout, 'mech_Watt_avg');
                results(end,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, mean(avgPower.Values.Data(end-50:end))];
            end
        end
    end
end