clear;clc;
simSweep = 1;
%seaHeights = 0.5:0.5:3;
seaHeights = 0.5%[1 2 3];
%seaPeriods = 4:0.25:10;
%seaPeriods = 0.5:0.5:4.5;
%seaPeriods = [6 8 10];
seaPeriods = 5:0.1:6.5;
seaDirection = 0;
ptoDamping = 500; % PTO damping coefficients
ptoStiffnesses = [100 1000 3000 5000 10000 15000]; % PTO spring stiffness
%ptoStiffnesses = [1000 5000 15000];

swellHeight = 0;
swellPeriod = 1;

results.waveHeight_row = seaHeights;
results.wavePeriod_col = seaPeriods;
results.ptoAvgPower = nan(length(seaHeights), length(seaPeriods), length(ptoStiffnesses));
results.ratioTimeCableNotTensed = results.ptoAvgPower;
results.avgSpeed = results.ptoAvgPower;
results.lookupTable = nan(length(seaHeights)*length(seaPeriods)*length(ptoStiffnesses), 5); % [seaHeight, seaPeriod, ptoStiffness, ptoDamping, ptoMechEnergy, ratioTimeCableNotTensed]
resultsQ = 1;

fid = fopen('wecSimInputFile.m');
wecSimInputScript = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

for ptoStiffness = ptoStiffnesses
    for seaHeight = seaHeights
        for seaPeriod = seaPeriods
            %try
                results.lookupTable(resultsQ, 1:4) = [seaHeight, seaPeriod, ptoStiffness, ptoDamping];
                startTime = tic;
                avgStartTime = 200; % time to start averaging
                wecSim;
                runTime = toc(startTime);

                simtime = output.wave.time;
    
                %damperSpeed = output.ptos.velocity(:,3);
                %ptoMechPower = ptoDamping * damperSpeed.^2;
                %ptoTime = damperPower.Values.Time;
                %desal_water = get(logsout, "permeateTotal_L");
                %inds = (simtime >= avgStartTime);
                %avg_desal_rate = (desal_water.Values.Data(end) - desal_water.Values.Data(simtime == avgStartTime)) / (simtime(end) - avgStartTime); % L/s
                %ptoMechEnergy = sum(diff(simtime(inds)).*ptoMechPower(inds(1:end-1)));
                %ptoAvgPower = mean(ptoMechPower(inds));
                ptoAvgPowerSig = get(logsout, 'pto_avg_power');
                ptoAvgPower = ptoAvgPowerSig.Values.Data(end);
                results.lookupTable(resultsQ, 5) = ptoAvgPower;
                ind = [find(seaHeights == seaHeight), find(seaPeriods == seaPeriod), find(ptoStiffnesses == ptoStiffness)];
                results.ptoAvgPower(ind(1), ind(2), ind(3)) = ptoAvgPower;
    
                cableTens = output.cables.forceTotal(:,3);
                indsC = (output.cables.time >= avgStartTime & cableTens == 0);
                timeDiff = diff(output.cables.time);
                timeCableNotTensed = sum(timeDiff(indsC(1:end-1)));
                ratioTimeCableNotTensed = timeCableNotTensed / (output.cables.time(end) - avgStartTime);
                %results(resultsQ, 4) = ratioTimeCableNotTensed;
                results.ratioTimeCableNotTensed(ind) = ratioTimeCableNotTensed;
                results.lookupTable(resultsQ, 6) = ratioTimeCableNotTensed;   
            %end
            resultsQ = resultsQ + 1;
        end
    end
end

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');
dataSaveFolder = 'results';
filename = sprintf('%s\\cylinder_buoy_rev1_1D_resultsOnly_%s.mat', dataSaveFolder, runTimeStamp);
save(filename, "results", "wecSimInputScript", "runTimeStamp");

simSweep = 0;

%% plot

indices = ~isnan(results.lookupTable(:,1));
waveHeights = unique(results.lookupTable(indices,1))';
wavePeriods = unique(results.lookupTable(indices,2))';
ptoStiffnesses = unique(results.lookupTable(indices,3))';

figure(41)
clf
set(gcf, "Position", [100     100   900   950])

subplot(2,1,1)
hold on
grid on
xlabel('Wave period (s)')
ylabel('Avg. power (W)')
legend('Location','northwest')

subplot(2,1,2)
hold on
grid on
xlabel('Wave period (s)')
ylabel('Power coeff. (-)')
legend('Location','northwest')

%lineColors = orderedcolors("gem");
%q = 1;
for ptoStiffness = ptoStiffnesses
    indices = results.lookupTable(:,3) == ptoStiffness;
    %plot(results.lookupTable(indices, 2), results.lookupTable(indices, 3), '*', 'Color', lineColors(q,:), 'DisplayName', sprintf('Sim: H = %.2f m', waveHeight))
    subplot(2,1,1)
    plot(results.lookupTable(indices, 2), results.lookupTable(indices, 5), '*--', 'DisplayName', sprintf('PTO k = %.1f N/m', ptoStiffness))
    %q = q+1;
    %q(q > length(lineColors)) = 1;
    subplot(2,1,2)
    % wavePower = 1000 * 9.81^2 / 64 / pi * results.lookupTable(indices, 1).^2 .* results.lookupTable(indices, 2) * (0.690*2); % original
    wavePower = 1000 * 9.81^2 / 64 / pi * results.lookupTable(indices, 1).^2 .* results.lookupTable(indices, 2) * (1.21*2); % rev1
    plot(results.lookupTable(indices, 2), results.lookupTable(indices, 5)./wavePower, '*--', 'DisplayName', sprintf('PTO k = %.1f N/m', ptoStiffness))

end

% find max power at each wave period
maxPowerVec = [];
for wavePeriod = wavePeriods
    indices = results.lookupTable(:,2) == wavePeriod;
    maxPower = max(results.lookupTable(indices, 5));
    maxPowerVec(end+1,:) = [wavePeriod, maxPower];
end
subplot(2,1,1)
plot(maxPowerVec(:,1), maxPowerVec(:,2), 'ro--', 'MarkerSize', 15, 'DisplayName', 'Best Selection')
set(gca, 'FontSize', 18)
%ylim([0 700])

subplot(2,1,2)
set(gca, 'FontSize', 18)

%title(sprintf('%Cylinder buoy (1D heaving) -- %s', runTimeStamp), 'Interpreter','none')
