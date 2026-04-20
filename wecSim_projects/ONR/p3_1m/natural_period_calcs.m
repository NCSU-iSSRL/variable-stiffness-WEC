%% only considering upper cylinder
clear;clc;
figure(1)
clf
hold on
xlabel('Mass (kg)')
ylabel('Natural period (s)')
legend('Location', 'northwest')

for r = 0.16:0.02:0.3 % m
    A = pi*r^2;
    k = 1000*9.81*A;
    period = @(m) 2*pi ./ sqrt(k./m);
    
    m = 400:10:1500;
    
    plot(m, period(m), 'DisplayName', sprintf('r = %.2f m', r))
end

%% using baseline design
clear;clc;

results = [];

for scaleFactor = 1:10
    r_lower = 6*0.0254 * scaleFactor; % in --> mm
    h_lower = 5.28*0.0254 * scaleFactor;
    V_lower = pi*r_lower^2 * h_lower;
    
    r_upper = 2.5*0.0254 * scaleFactor;
    h_upper = 9.81*0.0254 * scaleFactor;
    V_upper = pi*r_upper^2 * h_upper;
    
    V_total = V_lower + V_upper;
    V_sumberged_equil = V_lower + 0.5 * V_upper;
    buoy_mass = V_sumberged_equil*1025;
    
    C_added = 1.2; % typical added mass coeff.

    total_mass = buoy_mass + C_added * 1000 * V_sumberged_equil;

    A = pi*r_upper^2;
    k = 1000*9.81*A;
    results(end+1, :) = [scaleFactor, 2*pi / sqrt(k/total_mass)];
end

figure(2)
clf
hold on
plot(results(:,1), results(:,2), 'o--')
xlabel('Scale factor (-)')
ylabel('Natural period (s)')
legend('Location', 'northwest')