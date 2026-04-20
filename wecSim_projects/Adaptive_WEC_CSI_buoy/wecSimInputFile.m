%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'csi_cylinder.slx';              % Simulink Model File
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 100;                         	% Wave Ramp Time [s]
simu.endTime=400;                               % Simulation End Time [s]
simu.dt = 0.01;                                  % Simulation time-step [s]

%% Wave Information  
% Regular Waves 
waves = waveClass("regular");                   % Initialize waveClass
waves.height = 0.2;                                  % Wave Height [m]
waves.period = 1;                                    % Wave Period [s]

%% Body Data
% Float
body(1) = bodyClass('hydroData/csi_cyl.h5');        % Initialize bodyClass for Float
body(1).geometryFile = 'geometry/csi_cyl.stl';    % Geometry File
body(1).mass = 1.143;                   % Mass [kg]
body(1).inertia = [0.0057 0.0057 0.0084];  % Moment of Inertia [kg*m^2]     
% 
% % Spar/Plate
% body(2) = bodyClass('hydroData/rm3.h5');        % Initialize bodyClass for Spar
% body(2).geometryFile = 'geometry/plate.stl';    % Geometry File
% body(2).mass = 'equilibrium';                   % Mass [kg]
% body(2).inertia = [94419614.57 94407091.24 28542224.82]; % Moment of Inertia [kg*m^2]

%% PTO and Constraint Parameters
% Floating (3DOF) Joint
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
constraint(1).location = [0 0 -0.8];                    % Constraint Location [m]
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 0];                    % Constraint Location [m]

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 5;                                   % PTO Stiffness [N/m]
pto(1).damping = 15;                             % PTO Damping [N/(m/s)]
pto(1).location = [0 0 -0.8];                           % PTO Location [m]