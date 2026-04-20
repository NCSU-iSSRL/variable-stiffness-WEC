clear;clc;

% neutral angle = 54.44 deg.
% above this angle, the hose increases in length and its diameter decreases

alpha0 = 60 * pi/180;
L0 = 1;
r0 = 0.1;
r90 = r0 / sin(alpha0);
P = 1; % pressure

maxStrain = (1 / sqrt(3) / cos(alpha0)) - 1;
L = linspace(L0, L0*(1 + 2*maxStrain), 100);
% L/L0 = cos(alpha)/cos(alpha0) (eqn 8)
alpha = acos(L/L0 * cos(alpha0));

% r/r0 = sin(alpha)/sin(alpha0) (eqn 8)
r = r0 * sin(alpha) / sin(alpha0);

F_Schulte = pi * r90^2 * P * (3*cos(alpha).^2 - 1);

figure(1)
clf
subplot(3,1,1)
plot(L, alpha*180/pi)
xlabel('L')
ylabel('alpha (deg)')

subplot(3,1,2)
plot(L, r)
xlabel('L')
ylabel('Radius')

subplot(3,1,3)
plot(L, F_Schulte)
xlabel('L')
ylabel('Force (Schulte)')