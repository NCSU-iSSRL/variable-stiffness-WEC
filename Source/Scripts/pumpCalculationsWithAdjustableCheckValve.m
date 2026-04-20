clear; clc

% Values for 10-25 test, still need to find au with V-d tests
x_max = 3.8583/100;
lu = 29/100;
ru = 2.95/2/100; 
l0 = x_max+lu;
au = 48.5*pi/180; %54.7356  
a0 = acos(l0*cos(au)/lu);
r0 = ru*sin(a0)/sin(au);
Patm = 101325; %Pa
rt = 0.14/100; %0.32/100; %cm--m
mu = 0.001; %Pa*s
lt = 150/100; %cm--m
t = linspace(0,42,10000);
k_tube = 1170.8; %N/m  1219

% Prescribed displacement
T = 5;
x = (-x_max/2*cos(2*pi/T*t)+x_max/2) + 1.27/100;

% Calculatons based on x
setting = [10 20 30]*6894.75729; % Pressure regulator setting
type = 2; % 1 = Needle valve, 2 = regulator
[Qout,Qin,P,k,F] = pumpDisplacementCalcs(type,setting,ru,lu,au,x,t,k_tube,mu,lt,rt);

% Plots showing flow over time
figure(1)
clf
subplot(4,1,1); hold on
plot(t,x*100,'-k','LineWidth',0.7); ylabel('Displacement (cm)')
subplot(4,1,2)
hold on; box on
for i=1:length(setting)
    plot(t,Qout(:,i)*100^3,'LineWidth',0.7)
    plot(t,Qin(:,i)*100^3,'LineWidth',0.7)
end
ylabel('Flow rate (mL/s)'); legend('Out','In')
subplot(4,1,3); hold on; box on
for i=1:length(setting)
    plot(t,P(:,i)/6894.75729,'LineWidth',0.7)
end
legend('10 psi','20 psi','30 psi','Location','northeast'); yline(0,'--k','HandleVisibility','off'); ylabel('Pressure (psi)')
subplot(4,1,4); hold on; box on
for i=1:length(setting)
    plot(t,k(:,i),'LineWidth',0.7)
end
legend('10 psi','20 psi','30 psi','Location','northeast');
ylabel('k (N/m)')
xlabel('Time (s)')
