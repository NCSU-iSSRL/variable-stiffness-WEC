clear;clc;
% sizing calcs for simple cylindrical buoy
target_mass = 500; % kg
target_nat_period = 5; % sec
target_resting_waterline = 0.5; % fraction of total buoy height

wn = 2*pi/target_nat_period;
k_buoyancy_req = wn^2 * target_mass;
CSA_req = k_buoyancy_req / 1000 / 9.81;
radius_req = sqrt(CSA_req / pi);
subsea_height_req = target_mass / 1000 / CSA_req;
total_height_req = subsea_height_req / target_resting_waterline;
topside_height_req = total_height_req - subsea_height_req;

AR = total_height_req / (2*radius_req); % b^2/S = b/d

%% target AR
clear;clc;

syms target_nat_period
syms target_AR
syms target_resting_waterline
syms mass_req_sym

wn = 2*pi/target_nat_period;
k_buoyancy_req = wn^2 * mass_req_sym;
CSA_req = k_buoyancy_req / 1000 / 9.81;
radius_req = sqrt(CSA_req / pi);

total_height_req = target_AR * 2*radius_req; % AR = b^2/s = b^2 / (b*d) = b/d
subsea_height_req = total_height_req * target_resting_waterline;
topside_height_req = total_height_req * (1 - target_resting_waterline);

eq1 = mass_req_sym == 1000 * subsea_height_req * CSA_req;
mass_req_eqn = solve(eq1, mass_req_sym)

%%%
target_nat_period = 5; % sec
target_AR = 6; 
target_resting_waterline = 0.75; % fraction of total buoy height
mass_req = eval(mass_req_eqn(2))

wn = 2*pi/target_nat_period;
k_buoyancy_req = wn^2 * mass_req;
CSA_req = k_buoyancy_req / 1000 / 9.81;
radius_req = sqrt(CSA_req / pi);

total_height_req = target_AR * 2*radius_req; % AR = b^2/s = b^2 / (b*d) = b/d
subsea_height_req = total_height_req * target_resting_waterline;
topside_height_req = total_height_req * (1 - target_resting_waterline);

%% bottom plunger section sizing
clear;clc;
volume = 4.64; % m3, maintain this volume
r1 = 1.38/2; % base radius
angleChamfer = 45; % deg, angle of chamfer/loft from base radius to max radius

targetHeight = 1; % m

syms rMax hFrust hCyl

eq1 = targetHeight == hFrust + hCyl;
eq2 = rMax == r1 + tand(45)*hFrust;
eq3 = volume == (pi * rMax^2 * hCyl) + (1/3 * pi * hFrust * (r1^2 + rMax^2 + r1*rMax));

sol = solve([eq1 eq2 eq3])