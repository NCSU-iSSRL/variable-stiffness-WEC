%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'plunger3_1m_TG.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
if ~exist("simSweep", "var")
    simSweep = 0;
end
if ~simSweep
    simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 300;                               % Simulation End Time [s]
else
    simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 300;                               % Simulation End Time [s]
end
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 15;                         	% Wave Ramp Time [s]
power_avg_start_time = 120; % time to start measuring average power (start after wave ramp-up)
simu.dt = 0.03;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt), integrator errors with obe1be
%simu.solver = 'ode4'; % noisy signal in ACV with ode4
simu.saveWorkspace = 0;
simu.cicEndTime = 4;

%% Wave Information  
% Regular Waves 
waves = waveClass("regularCIC");                   % Initialize waveClass
if ~simSweep
    waves.height = 1;                                  % Wave Height [m]
    waves.period = 8;                                    % Wave Period [s]
    charLength = 1; % characteristic length for wave pow eqn, lower cylinder diameter
    wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period * charLength;
    waves.marker.location = linspace(-3, 3, 30)';
    waves.marker.location(:,2) = 0;
else
    waves.height = waveHeight;
    waves.period = wavePeriod;
end

%% Body Data
% Float
% Note: Body origin is at CG location set in AQWA
body(1) = bodyClass('hydroData/plunger3_1m.h5');        % Initialize bodyClass for Float, -190mm most closely matches actual buoy
body(1).geometryFile = 'geometry/plunger3_1m.stl';    % Geometry File
body(1).mass = 300;
body(1).inertia = body(1).mass * [0.161 0.161 0.1006];  % Moment of Inertia [kg*m^2]   
body(1).initial.displacement = [0 0 -1.8];
body(1).nonlinearHydro = 2;

body.quadDrag.area = [0.0771 0.0771 pi/4*(0.305^2) 0 0.041 0] * 3.2808399^2;
body.quadDrag.cd = [1 1 1 0 1 0];

%% Hose pump parameters
%HP_max_stretch = 3.8583/100;
HP_unstretched_length = 10; % m
HP_unstretched_radius = 0.06;
HP_unstretched_fiber_angle = 0.85; % rad
R_inlet = 0.02; % m, inlet tube radius
mu = 0.001; %Pa*s
L_inlet = 0.1; %m, inlet tube length
HP_bladder_elastic_modulus = 2e6; 
HP_unstretched_wall_thickness = 0.006; % m
HP_flowrate_damping_coefficient = 0; % N/(m3/s)

% NeuMotors 3805/18/522
kV = 522; % RPM/V
kT = 0.0183; % Nm/A
Rm = 0.261; % Ohm

% NeuMotors 2515 I/3.25D/339
% kV = 339; % RPM/V
% kT = 0.028225; % Nm/A
% Rm = 0.013; % Ohm

R_load = 2; % 0.8375; % Ohm
gen_eta = 1; % generator efficiency, <=1
turbine_D = 1 / (5 * 1000); % 1 / (rev/L * L/m3) --> m3/rev

PTO_capacity_W = 2000;

if ~simSweep
    turbine_gear_ratio = 7;
else % set G or reg. setting from sweep script
end

%% PTO and Constraint Parameters
% rotational joint at reaction plate
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
%constraint(1).location = [0 0 -1];

% bridle at bottom of buoy
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -0.834] + body.initial.displacement;  % Constraint Location [m]

constraint(1).location = constraint(2).location + [0 0 -1*HP_unstretched_length];

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 0;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 30;                             % PTO Damping [N/(m/s)]
%pto(1).location = [0 0 -0.1341-0.1] + body.initial.displacement;       % PTO Location [m]
pto(1).location = constraint(1).location;
%pto(1).hardStops.upperLimitSpecify = 'on';
%pto(1).hardStops.upperLimitBound = 0.05;
%pto(1).initial.displacement = [0 0 HP_unstretched_length];
%pto(1).hardStops.upperLimitBound = 0.1;%0.95*(HP_max_stretch);

cable(1) = cableClass('Cable1', 'pto(1)',  'constraint(2)');
cable(1).stiffness = 10000;
cable(1).damping = 100;
cable(1).cableLength = norm(constraint(2).location - constraint(1).location);