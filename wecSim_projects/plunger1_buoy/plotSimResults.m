%% plot
figure(1)
clf
ax1 = subplot(4,1,1);
plot(simu.time, output.wave.elevation, 'DisplayName', 'Wave', 'LineWidth', 1)
hold on
plot(simu.time, output.bodies.position(:,3), 'DisplayName', 'Buoy', 'LineWidth', 1)
%xlabel('Time (s)')
ylabel('Z-Axis / Elevation (m)')
legend()
grid on

ax2 = subplot(4,1,2);
plot(simu.time, output.bodies.position(:,1), 'LineWidth', 1, 'Color', "#D95319")
ylabel('X-Axis / Translation (m)')
grid on

ax3 = subplot(4,1,3);
plot(simu.time, output.bodies.position(:,5)*180/pi, 'LineWidth', 1, 'Color', "#D95319")
ylabel('Rotation about Y-Axis (deg.)')
grid on

ax4 = subplot(4,1,4);
plot(simu.time, -1*(output.ptos.powerInternalMechanics(:,3)), 'LineWidth', 1, 'Color', "#D95319")
ylabel('PTO Mechanical Power (W)')
grid on

linkaxes([ax1 ax2 ax3 ax4], 'x')
%xlim([0 150])
xlabel('Time (s)')
%set(gcf, "Position", 1e3*[0.6703    0.1377    1.6453    1.2006])
% for q = 1:4
% fontsize('increase')
% end
