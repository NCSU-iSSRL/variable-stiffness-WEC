%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'cylinder_buoy_1D_sim.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
if ~exist("simSweep", "var")
    simSweep = 0;
end
if ~simSweep
    simu.explorer = 'on';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 60;                               % Simulation End Time [s]
else
    simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 500;                               % Simulation End Time [s]
end
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 90;                         	% Wave Ramp Time [s]
simu.dt = 0.005;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt), integrator errors with obe1be
%simu.solver = 'ode4'; % noisy signal in ACV with ode4
simu.saveWorkspace = 0;

%% Wave Information  
% Regular Waves 
waves = waveClass("regular");                   % Initialize waveClass
if ~simSweep
    waves.height = 1;                                  % Wave Height [m]
    waves.period = 6;                                    % Wave Period [s]
    charLength = 1; % characteristic length for wave pow eqn, lower cylinder diameter
    wavePower = 1000*9.81^2/64/pi * waves.height^2 * waves.period * charLength;
    waves.marker.location = linspace(-3, 3, 30)';
    waves.marker.location(:,2) = 0;
else
    waves.height = seaHeight;
    waves.period = seaPeriod;
end

%% Body Data
% Float
% Note: Body origin is at CG location set in AQWA
body(1) = bodyClass('hydroData/cylinder_buoy_rev1.h5');        % Initialize bodyClass for Float, -190mm most closely matches actual buoy
body(1).geometryFile = 'geometry/cylinder_buoy_rev1.stl';    % Geometry File

body(1).mass = 9455;
body(1).inertia = [55143 55143 2250];  % Moment of Inertia [kg*m^2]   
body(1).initial.displacement = [0 0 0];
%body(1).nonlinearHydro = 2;

%body.quadDrag.area = [0.0771 0.0771 pi/4*(0.305^2) 0 0.041 0] * 3.2808399^2;
body.quadDrag.area = [0 0 0*pi * (1.21^2 - 0.69^2) 0 0 0];
body.quadDrag.cd = [0 0 0.1*0 0 0 0];


%% PTO and Constraint Parameters
% rotational joint at reaction plate
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
%constraint(1).location = [0 0 -1];

% bridle at bottom of buoy
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -6.21] + body.initial.displacement;  % Constraint Location [m]

constraint(1).location = constraint(2).location + [0 0 -6];

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
if ~simSweep
    pto(1).stiffness = 1000;%534;                                   % PTO Stiffness [N/m]
    pto(1).damping = 500;                             % PTO Damping [N/(m/s)]
else
    pto(1).stiffness = ptoStiffness;
    pto(1).damping = ptoDamping;
end
%pto(1).location = [0 0 -0.1341-0.1] + body.initial.displacement;       % PTO Location [m]
pto(1).location = constraint(1).location;
%pto(1).hardStops.upperLimitSpecify = 'on';
%pto(1).hardStops.upperLimitBound = 0.05;
%pto(1).initial.displacement = [0 0 HP_unstretched_length];
%pto(1).hardStops.upperLimitBound = 0.1;%0.95*(HP_max_stretch);

cable(1) = cableClass('Cable1', 'pto(1)',  'constraint(2)');
cable(1).stiffness = 100000;
cable(1).damping = 100;
cable(1).cableLength = norm(constraint(2).location - constraint(1).location);