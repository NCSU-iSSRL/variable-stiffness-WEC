clear;clc;
Tn = 7; % sec, target nat. freq
wn = 2*pi/Tn;
syms rB

%rB = 10; % m, buoy radius
hB = 5*rB; % m, buoy height

rhoW = 1025; % kg/m3
rhoB = 6*146.84; % kg/m3
%rhoB = 1000;
kB = rhoW*9.81*pi*rB^2;
kS = 0.25*kB;
kT = kB + kS;

%mAdded = pi*rB^2*hB*rhoW;

m = rhoB*pi*rB^2*hB;

eq1 = wn == sqrt(kT/m)
rB = eval(solve(eq1, rB))
hB = eval(hB)
kB = eval(kB)
kS = eval(kS)
m = eval(m)