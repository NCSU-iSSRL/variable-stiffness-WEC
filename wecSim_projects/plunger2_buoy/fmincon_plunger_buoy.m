clear;clc;
waveHeights = 0.08;
wavePeriods = 0.75:0.25:2;
results = [];

for waveHeight = waveHeights
    for wavePeriod = wavePeriods
        results(end+1,:) = [nan nan nan nan];
        fun = @(x) -1*run_plunger_sim(waveHeight, wavePeriod, x);
        options = optimoptions('fmincon','StepTolerance', 0.01, 'MaxIterations', 50);
        G_opt = fmincon(fun, 1, [], [], [], [], 0.1, 20, [], options);
        optPower = run_plunger_sim(waveHeight, wavePeriod, G_opt);
        results(end,:) = [waveHeight, wavePeriod, G_opt, optPower];
    end
end

function avgPower = run_plunger_sim(waveHeight_in, wavePeriod_in, G_in)
    waveHeight = waveHeight_in;
    wavePeriod = wavePeriod_in;
    G = G_in;
    avgPower = -1;
    try 
        wecSim
        avgPowerTs = get(logsout, 'mech_Watt_avg');
        avgPower = avgPowerTs.Values.Data(end);
    end
end