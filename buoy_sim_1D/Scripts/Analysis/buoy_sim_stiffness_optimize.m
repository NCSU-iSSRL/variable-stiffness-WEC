%% param sweep
clear;clc;

startFolder = "buoy_simulation"; % change this to set your starting folder
folder = strsplit(cd, '\');
if folder{end} ~= startFolder
    disp('Incorrect path. Move to ''CSI WEC\buoy_simulation'' folder')
    return
end
runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');

wave_amplitude = 1; % m
wave_period_sweep = 0.5:0.125/10:5;
spring_const_sweep = 500:500:5000;
sweepResults = []; % [waveAmplitude, wavePeriod, springConst, responseAmplitude]

saveFig = true;

f = waitbar(0,'Running simulations...');
count = 0;
for spring_const = spring_const_sweep
    for wave_period = wave_period_sweep
        tsc = sim("buoy_sim_v1.slx", "StopTime", "30");
        plotSelect = false;
        responseAmplitude = analyzeBuoySimData(tsc, plotSelect);
        sweepResults(end+1,:) = [wave_amplitude, wave_period, spring_const, responseAmplitude/wave_amplitude];
    end
    count = count + 1;
    waitbar(count/length(spring_const_sweep),f,'Running simulations...');
end
close(f)

figure(1)
clf
hold on
legend('Location','southeast')
xlabel('Wave period (s)')
ylabel('Buoy response amp. (non-dimen.) (A_buoy/A_waveSurf)', 'Interpreter','none')
for spring_const = spring_const_sweep
    inds = sweepResults(:,3) == spring_const;
    plot(sweepResults(inds,2), sweepResults(inds,4),'DisplayName', sprintf('Spring const. = %.1f N/m', spring_const))
    [~, maxInd] = max(sweepResults(inds,4));
    temp = find(inds);
    maxInd = temp(maxInd);
    clear temp
    plot(sweepResults(maxInd,2), sweepResults(maxInd,4), 'ro', 'HandleVisibility','off')
end
plot(sweepResults(maxInd,2), sweepResults(maxInd,4), 'ro', 'DisplayName','Location of max. response amplitude') % plot last marker again to add legend entry
title(sprintf('Non-dimen. buoy response amplitude vs. wave period. Wave amplitude = %.1f m.', wave_amplitude))
savefig([pwd, '\figures\', sprintf('buoyResponseAmplitude_vs_wavePeriod__waveAmplitude_%02.2f__', wave_amplitude), runTimeStamp, '.fig'])
%% functions
function responseAmplitude = analyzeBuoySimData(tsc, plotSelect)
    x_CG = get(tsc.logsout, 'x_CG');
    
    if plotSelect
        figure(183)
        clf
        plot(x_CG.Values)
        hold on
    end
    
    xDot_CG = get(tsc.logsout, 'xDot');
    xDotValues = [nan nan];
    zeroCrossings = zeros(1, length(xDot_CG.Values.Time));
    for q = 1:length(xDot_CG.Values.Time)
        if xDot_CG.Values.Time(q) >= 10
            xDotValues(1) = xDotValues(2);
            xDotValues(2) = xDot_CG.Values.Data(q);
            
            if xDotValues(2)/xDotValues(1) < 0
                zeroCrossings(q) = 1;
                if false %plotSelect
                    plot(xDot_CG.Values.Time(q), x_CG.Values.Data(q), 'ro')
                end
            end
        end
    end
    
    peakValues = x_CG.Values.Data(boolean(zeroCrossings));
    avgPosPeak = mean(peakValues(peakValues > mean(peakValues)));
    avgNegPeak = mean(peakValues(peakValues < mean(peakValues)));
    responseAmplitude = 0.5*(avgPosPeak - avgNegPeak);
end