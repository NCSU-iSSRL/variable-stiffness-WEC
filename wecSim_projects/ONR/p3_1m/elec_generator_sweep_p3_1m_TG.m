% given a regulator setting, find the best wave period
clear;clc;
waveHeight = 1.5;
wavePeriod = 6;
turbine_gear_ratio = 2;
results = [];
simData = {};

simSweep = 1; % flag used in wecSimInputFile

fid = fopen('wecSimInputFile_p3_1m_TG.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

NeuMotorsproductmatrix = importNMproductMatrix("C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\wecSim_projects\ONR\p3_1m\NeuMotors_product_matrix.xlsx", ...
    "25xx", [4, Inf]);
NeuMotorsSpecs = table2array(NeuMotorsproductmatrix(:, 2:end));
NeuMotorsSpecs(:, end+1) = nan;
powerMatrix = nan(height(NeuMotorsproductmatrix), 1);

for productQ = 1:4:length(powerMatrix)
    kV = NeuMotorsSpecs(productQ, 1); % RPM/V
    kT = NeuMotorsSpecs(productQ, 4)/1000; % Nm/A
    Rm = NeuMotorsSpecs(productQ, 2); % Ohm
    results(end+1,:) = [waveHeight, wavePeriod, turbine_gear_ratio, nan, nan];
    try
        wecSim;
        %maxPower = max(output.ptos.powerInternalMechanics(simu.time>120,3));
        avgPower = get(logsout, 'elec_Watt_avg');
        meanPower = mean(avgPower.Values.Data(end-1000:end));
        HP_strain = get(logsout, 'HP_strain');
        results(end,4:5) = [meanPower, max(HP_strain.Values.Data(end-1000:end))];
        simData{end+1}.wavePeriod = wavePeriod;
        simData{end}.waveHeight = waveHeight;
        simData{end}.turbine_gear_ratio = turbine_gear_ratio;
        simData{end}.signalLogs = logsout;
        powerMatrix(productQ) = meanPower;
        NeuMotorsSpecs(productQ, end) = meanPower;
    end
end
simSweep = 0; % flag used in wecSimInputFile

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
