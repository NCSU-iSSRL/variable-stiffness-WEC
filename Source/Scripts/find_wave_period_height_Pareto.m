% Pull in wave data from CDIP buoy
% For each unique wave period bin, find the highest observed wave height
%  to generate a Pareto-like frontier.
% Use this frontier to inform which wave conditions to simulate.
clear;clc;

dataFolder = 'E:\CDIP_buoy_data\';

files = dir([dataFolder, '192*.nc']);

figure(1)
clf
hold on
xlabel('Wave period (s)')
ylabel('Sig. wave height (m)')

wavePeriodBinWidth = 0.05; % s, width of wave period bin to seach for highest observed wave height

for q = 1:length(files)
    disp(files(q).name)
    
    historicalDataFile = [files(q).folder, '\', files(q).name];
    time = ncread(historicalDataFile, 'waveTime'); % seconds since epoch
    sigWaveHeight = ncread(historicalDataFile, 'waveHs'); % m
    waveAvgPeriod = ncread(historicalDataFile, 'waveTa'); % s
    stationID = string(ncread(historicalDataFile, 'metaStationName')'); % s
    stationNum = str2double(files(q).name(1:3));

    %plot(waveAvgPeriod, sigWaveHeight, '.')

    wavePeriodSearchBin = [min(waveAvgPeriod), min(waveAvgPeriod) + wavePeriodBinWidth];
    maxWaveAvgPeriod = max(waveAvgPeriod);
    maxWaveHeightResults = [];

    while wavePeriodSearchBin(2) < maxWaveAvgPeriod
        wavePeriods = waveAvgPeriod((waveAvgPeriod >= wavePeriodSearchBin(1)) & (waveAvgPeriod < wavePeriodSearchBin(2)));
        waveHeights = sigWaveHeight((waveAvgPeriod >= wavePeriodSearchBin(1)) & (waveAvgPeriod < wavePeriodSearchBin(2)));

        if ~isempty(wavePeriods)
            [maxWaveHeight, maxInd] = max(waveHeights);
            [minWaveHeight, minInd] = min(waveHeights);
            
            maxWaveHeightResults(end+1, :) = [wavePeriods(maxInd), maxWaveHeight, minWaveHeight];
        end
        
        wavePeriodSearchBin = wavePeriodSearchBin + wavePeriodBinWidth;
    end
    plot(maxWaveHeightResults(:,1), maxWaveHeightResults(:,2), 'r', 'HandleVisibility','off')
    plot(maxWaveHeightResults(:,1), maxWaveHeightResults(:,3), 'g', 'HandleVisibility','off')
end

linFrontier = @(x) 1.2032*x - 2.2521 + 0.25;
quadFrontier = @(x) 0.1023*x.^2 + 0.0318*x + 0.0501 + 0.25;
periods = 2:12;
plot(periods, linFrontier(periods), 'DisplayName', 'Linear frontier')
plot(periods, quadFrontier(periods), 'DisplayName', 'Quadratic frontier')
legend()

%% estimate number of simulations
% From historical data (USA CDIP buoys), the Pareto-like frontier defining
%   typical max. wave height vs. wave period follows an approximately linear
%   form as H = 1.2032*T - 2.2521
%   or quadratic form as H = 0.1023*T^2 + 0.0318*T + 0.0501
% So, any wave conditions above this line (wave height above line for a
%   given wave period) need not be simulated.
%
% The NREL Marine Energy Atlas specifies simulation matrices with bins:
%   Sig. wave height: 0.25m to 9.75m center values with 0.5m bins
%   Energy period: 0.5s to 20.5s center values with 1s bins

waveHeights = linspace(0.1, 8, 12);
wavePeriods = linspace(1.75, 10, 12);
% waveHeights = 0.25:0.5:9.75; % NREL
% wavePeriods = 0.5:1:20.5; % NREL

numSims = 0;

for waveHeight = waveHeights
    for wavePeriod = wavePeriods
        if waveHeight <= 0.1023*wavePeriod.^2 + 0.0318*wavePeriod + 0.0501 + 0.25 % 1.2032*wavePeriod - 2.2521 + 0.25
            % perform simulation
            numSims = numSims+1;
        end
    end
end