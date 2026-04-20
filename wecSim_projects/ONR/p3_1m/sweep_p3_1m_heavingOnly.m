% given a regulator setting, find the best wave period
clear;clc;
waveHeights = 0.15;
%wavePeriods = 2:0.5:8;
wavePeriods = 4:0.2:6;
%wavePeriods = [2.4:0.1:3, 3.5, 4, 4.5:0.1:5.5, 6, 7, 8];
regulator_set_pressure_PSI_in = 9;
powerMatrix = nan(length(waveHeights), length(wavePeriods), length(regulator_set_pressure_PSI_in));
results = [];
simData = {};

simSweep = 1; % flag used in wecSimInputFile

fid = fopen('wecSimInputFile.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

figure(11)
clf
hold on
xlabel('Wave period (s)')
ylabel('Peak buoy Z acc. (m/s2)')
%legend('Location', 'northwest')

for regulatorQ = 1:length(regulator_set_pressure_PSI_in)
    for waveHeightQ = 1:length(waveHeights)
        for wavePeriodQ = 1:length(wavePeriods)
            waveHeight = waveHeights(waveHeightQ);
            wavePeriod = wavePeriods(wavePeriodQ);
            regulator_set_pressure_PSI = regulator_set_pressure_PSI_in(regulatorQ);
            results(end+1,:) = [waveHeight, wavePeriod, regulator_set_pressure_PSI, nan, nan];
            %try
                wecSim;
                %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
                avgPower = get(logsout, 'mech_Watt_avg');
                HP_strain = get(logsout, 'HP_strain');
                buoy_Z_acc = get(logsout, 'buoy_Z_acc');
                figure(11)
                %plot(buoy_Z_acc.Values.Time, buoy_Z_acc.Values.Data, 'DisplayName', sprintf('T = %.2f s', wavePeriod))
                plot(wavePeriod, max(buoy_Z_acc.Values.Data(end-1000:end)), 'ro')
            %end
        end
    end
end
simSweep = 0; % flag used in wecSimInputFile

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');

