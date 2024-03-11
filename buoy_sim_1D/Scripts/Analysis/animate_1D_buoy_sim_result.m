close all
% have tsc loaded in workspace
x_CG = get(tsc.logsout, 'x_CG');
water_height = get(tsc.logsout, 'water_height');
buoy_height = 17.7;
buoy_radius = 3.5;

refresh_rate = 1/10;

figure(5)
clf
%h = animatedline('Color', 'k', 'Marker','o');
xlim([-5 5])
ylim([-8 2])
tic

runTimeStamp = datestr(now, 'YYYY_mm_DD_HH_MM_ss');

V = VideoWriter(['C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\buoy_sim_1D\Figures\buoy_simple_animation_', runTimeStamp, '.mp4'], "MPEG-4");
open(V)
%F = struct('cdata',[],'colormap',[]);
%F(1) = getframe(gcf);
for q = 1:(length(x_CG.Values.Time)-1)
    pause((x_CG.Values.Time(q+1) - x_CG.Values.Time(q)))
    if toc >= refresh_rate % update plot
        tic
        %clearpoints(h);
        %addpoints(h, 0, x_CG.Values.Data(q))
        clf
        plot(0, x_CG.Values.Data(q), 'ko')
        hold on
        rectangle_corner = [-buoy_radius/2, x_CG.Values.Data(q) - buoy_height/2];
        rectangle('Position', [rectangle_corner, buoy_radius, buoy_height])
        plot([-100 100], water_height.Values.Data(q)*[1 1], 'c', 'LineWidth', 1.5)
        xlim([-5 5])
        ylim([-15 10])
        
        title(sprintf('t = %.3f sec', x_CG.Values.Time(q)))
        drawnow limitrate
        
        %F(end+1) = getframe(gcf);
        writeVideo(V, getframe(gcf))
    end
end

%fig = figure(6);
%movie(fig, F, 1, 1/refresh_rate)
close(V)