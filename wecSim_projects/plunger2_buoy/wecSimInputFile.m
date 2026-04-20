%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'plunger2.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
if ~exist("simSweep", "var")
    simSweep = 0;
end
if ~simSweep
    simu.explorer = 'on';                   % Turn SimMechanics Explorer (on/off)
else
    simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
end
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 15;                         	% Wave Ramp Time [s]
power_avg_start_time = 45; % time to start measuring average power (start after wave ramp-up)
simu.endTime = 30%75;                               % Simulation End Time [s]
simu.dt = 0.01;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt)
%simu.solver = 'ode4';
%simu.solver = 'ode23t';
simu.saveWorkspace = 0;

%% Wave Information  
% Regular Waves 
waves = waveClass("regular");                   % Initialize waveClass
if ~simSweep
    waves.height = 0*0.1;                                  % Wave Height [m]
    waves.period = 1.0;                                    % Wave Period [s]
    charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
    wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period * charLength;
else
    waves.height = waveHeight;
    waves.period = wavePeriod;
    simu.endTime = 75;                               % Simulation End Time [s]
end

waves.waterDepth = 2;
waves.marker.location = linspace(-1, 1, 30)';
waves.marker.location(:,2) = 0;

%wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period;
%% Body Data
% Float
% Note: Body origin is at CG location set in AQWA
body(1) = bodyClass('hydroData/plunger2_cg-190mm.h5');        % Initialize bodyClass for Float, -190mm most closely matches actual buoy
body(1).geometryFile = 'geometry/plunger2.stl';    % Geometry File
%body(1).mass = 11.2 - 2.3;                   % Mass [kg]
body(1).mass = 8.838 + 2.3; % kg
%body(1).inertia = [0.122 0.122 0.0819];  % Moment of Inertia [kg*m^2]   
body(1).inertia = [0.0606 0.0606 0.0466];
body.initial.displacement = [0 0 -0.13];
% body.initial.angle = 10*pi/180;

%body.morisonElement.option = 1;
%body.morisonElement.cd = [0.2 0.2 0.5];
%body.morisonElement.area = [0.041 0.041 0.0730];
%body.morisonElement.area = [0.0725 0.0725 0.0603];
%body.morisonElement.ca = 0.1*[1 1 1]; % added mass removed during P1 model-data matching
%body.morisonElement.VME = 0.013; % total volume of upper and lower cylinders
% 
% body.quadDrag.area = [0 0 0 0 0.041 0];
% body.quadDrag.cd = [0 0 0 0 0.075 0]; % drag on pitching motion
body.quadDrag.area = [0.0725 0.0725 0.0603 0 0.041 0];
body.quadDrag.cd = [0.2 0.2 0 0 0.02 0];

%% PTO and Constraint Parameters
% rotational joint
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
constraint(1).location = [0 0 -1];
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -0.1341-0.1] + body.initial.displacement;  % Constraint Location [m]
% constraint(3) = constraintClass('Constraint3'); % Initialize constraintClass for Constraint1
% constraint(3).location = constraint(1).location;

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 0;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 0*20;                             % PTO Damping [N/(m/s)]
%pto(1).location = [0 0 -0.1341-0.1] + body.initial.displacement;       % PTO Location [m]
pto(1).location = constraint(1).location;

cable(1) = cableClass('Cable1', 'pto(1)',  'constraint(2)');
cable(1).stiffness = 10000;
cable(1).damping = 100;

%% Hose pump parameters
FAM_unstretched_length = 0.381;
FAM_unstretched_radius = 0.01;
hose_pump_max_stretch = 0.0582*(0.381/0.25)*2;
fiber_angle_alpha = 0.6981;
fiber_angle_alpha_unstr = acos(FAM_unstretched_length / (FAM_unstretched_length + hose_pump_max_stretch) * cos(fiber_angle_alpha));
FAM_stretched_radius = FAM_unstretched_radius*sin(fiber_angle_alpha)/sin(fiber_angle_alpha_unstr);
FAM_wall_thickness = 0.002;
FAM_elasticity = 1e6;

%%% hose pump v3 model
% HP_unstretched_length = 0.381;
% hose_pump_max_stretch = HP_unstretched_length*0.2;
% HP_unstretched_radius = 0.01; 
% L0 = hose_pump_max_stretch + HP_unstretched_length;
% fiber_angle_alpha_unstr = 48.5*pi/180; %54.7356  
% fiber_angle_alpha = acos(L0 * cos(fiber_angle_alpha_unstr) / HP_unstretched_length);
% HP_stretched_radius = HP_unstretched_radius * sin(fiber_angle_alpha) / sin(fiber_angle_alpha_unstr);
% Rt = 0.14/100; %0.32/100; %cm--m
% mu = 0.001; %Pa*s
% Lt = 150/100; %cm--m
% HP_spring_stiffness = 1170.8/5; %N/m  1219
%%% 

if ~simSweep
    regulator_set_pressure_PSI = 10;
    G = 1;
else % set G or reg. setting from sweep script
end

% kV = 890; % voltage constant, RPM/V, NeuMotors 705/25D/890
% kT = 0.0108; % torque constant, Nm/A
% Rm = 2.292; % motor winding resistance
% R_load = Rm; % load resistance
% turbine_D = 1/1000^2; % turbine rotation coefficient, m3/rev, 1.0cc/rev

hose_pump_force_enabled = 0;