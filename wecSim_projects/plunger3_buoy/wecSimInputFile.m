%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'plunger3_v2.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
if ~exist("simSweep", "var")
    simSweep = 0;
end
if ~simSweep
    simu.explorer = 'on';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 60;                               % Simulation End Time [s]
else
    simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 60;                               % Simulation End Time [s]
end
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 15;                         	% Wave Ramp Time [s]
power_avg_start_time = 30; % time to start measuring average power (start after wave ramp-up)
simu.dt = 0.01;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt), integrator errors with obe1be
%simu.solver = 'ode15s';
%simu.solver = 'ode23t';
%simu.solver = 'ode45';
%simu.solver = 'ode14x';
%simu.solver = 'ode4';
simu.saveWorkspace = 0;
simu.cicEndTime = 4;

%% Wave Information  
% Regular Waves 
waves = waveClass("regularCIC");                   % Initialize waveClass
if ~simSweep
    waves.height = 0.13*0;                                  % Wave Height [m]
    waves.period = 1.5;                                    % Wave Period [s]
    charLength = 0.305; % characteristic length for wave pow eqn, lower cylinder diameter
    wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period * charLength;
    waves.marker.location = linspace(-1, 1, 30)';
    waves.marker.location(:,2) = 0;
else
    waves.height = waveHeight;
    waves.period = wavePeriod;
end

%waves.waterDepth = 2;


%wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period;
%% Body Data
% Float
% Note: Body origin is at CG location set in AQWA
body(1) = bodyClass('hydroData/plunger3.h5');        % Initialize bodyClass for Float, -190mm most closely matches actual buoy
body(1).geometryFile = 'geometry/plunger3.stl';    % Geometry File
%body(1).mass = 11.2 - 2.3;                   % Mass [kg]
body(1).mass = 8.838;% + 2.3;% kg
%body(1).inertia = [0.122 0.122 0.0819];  % Moment of Inertia [kg*m^2]   
body(1).inertia = body(1).mass/8.5 .* [0.1098 0.1098 0.0779];
body(1).initial.displacement = [0 0 -0.06];
% body.initial.angle = 10*pi/180;
body(1).nonlinearHydro = 2;

body.morisonElement.option = 1;
%body.morisonElement.cd = [0.2 0.2 1];
%body.morisonElement.area = [0.041 0.041 0.0730];
%body.morisonElement.area = [0.0771 0.0771 pi/4*(0.305^2 - 0.127^2)];
%body.morisonElement.VME = 0.0140; % total volume of upper and lower cylinders
body.morisonElement.VME = 0.0118; % volume of just lower cylinder
%ca = 8 / (body.morisonElement.VME*1000); % approx. 8 kg added mass
%ca = 0.1;
%body.morisonElement.ca = ca*[1 1 1]; % added mass removed during P1 model-data matching

%body.quadDrag.area = [0 0 0 0 0.041 0];
%body.quadDrag.cd = [0 0 0 0 0.1 0]; % drag on pitching motion
%body.quadDrag.area = [0.0771 0.0771 pi/4*(0.305^2 - 0.127^2) 0 0.041 0];
body.quadDrag.area = [0.0771 0.0771 pi/4*(0.305^2) 0 0.041 0];
body.quadDrag.cd = [0.2 0.2 1 0 0.1 0];

%% Hose pump parameters
HP_max_stretch = 3.8583/100;
%HP_unstretched_length = 29/100;
HP_unstretched_length = 0.4064; % 16"
HP_unstretched_radius = 0.0223/2; % 22.3 mm OD 
%HP_unstretched_fiber_angle = 48.5*pi/180; %54.7356  
%HP_unstretched_fiber_angle = 52.3*pi/180; % measured from HP
HP_unstretched_fiber_angle = 0.917;
R_inlet = 0.2/100; %0.32/100; %cm--m, inlet tube radius
%R_inlet = 0.003; % inlet tube radius, 1/4" ID
mu = 0.001; %Pa*s
L_inlet = 150/100; %cm--m, inlet tube length
HP_bladder_elastic_modulus = 3e6; %1.2e6; %2.3e6; % value from Kothera text  
HP_unstretched_wall_thickness = 1*0.002; % m
HP_flowrate_damping_coefficient = 2.4e4; % N/(m3/s)


ACV_disk_radius = 0.007;
ACV_throat_length = 0.005;
ACV_inlet_length = 0.015;
ACV_expansion_factor = 1.02;

%pto(1).initial.displacement = [0 0 HP_unstretched_length];
%pto(1).hardStops.upperLimitSpecify = 'on';
%pto(1).hardStops.upperLimitBound = 0.1;%0.95*(HP_max_stretch);

if ~simSweep
    regulator_set_pressure_PSI = 5; % Pressure regulator setting
    G = 1;
else % set G or reg. setting from sweep script
end

%% PTO and Constraint Parameters
% rotational joint
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
%constraint(1).location = [0 0 -1];
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -0.254] + body.initial.displacement;  % Constraint Location [m]

constraint(1).location = constraint(2).location + [0 0 -1*HP_unstretched_length];

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 0;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 30;                             % PTO Damping [N/(m/s)]
%pto(1).location = [0 0 -0.1341-0.1] + body.initial.displacement;       % PTO Location [m]
pto(1).location = constraint(1).location;
%pto(1).hardStops.upperLimitSpecify = 'on';
%pto(1).hardStops.upperLimitBound = 0.05;

cable(1) = cableClass('Cable1', 'pto(1)',  'constraint(2)');
cable(1).stiffness = 10000;
cable(1).damping = 100;
cable(1).cableLength = norm(constraint(2).location - constraint(1).location);