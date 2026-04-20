%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'plunger1.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal'w,'accelerator','rapid-accelerator')
simu.explorer = 'on';                   % Turn SimMechanics Explorer (on/off)
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 30;                         	% Wave Ramp Time [s]
power_avg_start_time = 60;      % time to start measuring average power (start after wave ramp-up)
simu.endTime = 90;                               % Simulation End Time [s]
simu.dt = 0.01;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be';
simu.saveWorkspace = 0;

%% Wave Information  
% Regular Waves 
waves = waveClass("regular");                   % Initialize waveClass
waves.height = 0.08;                                  % Wave Height [m]
%waves.height = waveHeight;
waves.period = 1.25;                                    % Wave Period [s]
%waves.period = wavePeriod;

waves.waterDepth = 2;
waves.marker.location = linspace(-1, 1, 30)';
waves.marker.location(:,2) = 0;
%% Body Data
% Float
body(1) = bodyClass('hydroData/plunger1.h5');        % Initialize bodyClass for Float
body(1).geometryFile = 'geometry/plunger1.stl';    % Geometry File
body(1).mass = 7.5;                   % Mass [kg]
body(1).inertia = [0.0412 0.0412 0.0281];  % Moment of Inertia [kg*m^2]     
body.initial.displacement = [0 0 -0.12];%[0 0 -0.055];

body.morisonElement.option = 1;
body.morisonElement.cd = [0 0 1];
body.morisonElement.area = [0.0332 0.0332 0.0404];
% body.morisonElement.ca = [1 1 1];
% body.morisonElement.VME = 0.007386; % total volume of P1 buoy

body.quadDrag.area = [0 0 0 0 0.0408 0];
body.quadDrag.cd = [0 0 0 0 0.05 0];
% body(1).nonlinearHydro = 1;

% 
% % Spar/Plate
% body(2) = bodyClass('hydroData/rm3.h5');        % Initialize bodyClass for Spar
% body(2).geometryFile = 'geometry/plate.stl';    % Geometry File
% body(2).mass = 'equilibrium';                   % Mass [kg]
% body(2).inertia = [94419614.57 94407091.24 28542224.82]; % Moment of Inertia [kg*m^2]

%% PTO and Constraint Parameters
% rotational joint
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
constraint(1).location = [0 0 -0.1341-0.12 - 0.381] + body.initial.displacement;                    % Constraint Location [m]
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -0.1341-0.12] + body.initial.displacement;  % Constraint Location [m]

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 0;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 10;                             % PTO Damping [N/(m/s)]
pto(1).location = [0 0 -0.1341-0.12] + body.initial.displacement;       % PTO Location [m]

%% Hose pump parameters
FAM_unstretched_length = 0.381;
FAM_unstretched_radius = 0.01;
hose_pump_max_stretch = 0.0582*(0.381/0.25);
fiber_angle_alpha = 0.6981;
fiber_angle_alpha_unstr = acos(FAM_unstretched_length / (FAM_unstretched_length + hose_pump_max_stretch) * cos(fiber_angle_alpha));
FAM_stretched_radius = FAM_unstretched_radius*sin(fiber_angle_alpha)/sin(fiber_angle_alpha_unstr);
FAM_wall_thickness = 0.002;
FAM_elasticity = 1e6;

%regulator_set_pressure_PSI = 4;
G = 0.75;

kV = 890; % voltage constant, RPM/V, NeuMotors 705/25D/890
kT = 0.0108; % torque constant, Nm/A
Rm = 2.292; % motor winding resistance
R_load = Rm; % load resistance
turbine_D = 1/1000^2; % turbine rotation coefficient, m3/rev, 1.0cc/rev

%hose_pump_exp_throughflow = 0.115/5; % expected L/full-pump for hose pump (found experimentally)
%hose_pump_throughFlow_adjust = 1;%hose_pump_exp_throughflow / (1000*FAM_unstretched_length*pi*(FAM_unstretched_radius-FAM_wall_thickness)^2);

hose_pump_force_enabled = 1;