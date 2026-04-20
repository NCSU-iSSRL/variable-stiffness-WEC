%% Simulation Data
simu = simulationClass();                       % Initialize simulationClass
simu.simMechanicsFile = 'plunger3_1m_springDamper_1D.slx';              % Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
if ~exist("simSweep", "var")
    simSweep = 0;
end
if ~simSweep
    simu.explorer = 'on';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 60;                               % Simulation End Time [s]
else
    simu.explorer = 'off';                   % Turn SimMechanics Explorer (on/off)
    simu.endTime = 90;                               % Simulation End Time [s]
end
simu.startTime = 0;                             % Simulation Start Time [s]
simu.rampTime = 15;                         	% Wave Ramp Time [s]
power_avg_start_time = 30; % time to start measuring average power (start after wave ramp-up)
simu.dt = 0.01;                                  % Simulation time-step [s]
simu.domainSize = 2;
simu.solver = 'ode1be'; % ode1be hose-pump flowrate values match closest to experiment (ode4 also matches with very small simu.dt), integrator errors with obe1be
%simu.solver = 'ode4'; % noisy signal in ACV with ode4
simu.saveWorkspace = 0;

%% Wave Information  
% Regular Waves 
waves = waveClass("regular");                   % Initialize waveClass
if ~simSweep
    waves.height = 0;                                  % Wave Height [m]
    waves.period = 5;                                    % Wave Period [s]
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
% going to keep same ratio of buoy mass : max water displacement mass as
%   from wave tank testing (4.05 kg : 14.3 kg = 0.283)
% max displacement for 1m buoy = 504.2 kg
% --> set mass at 142.7 kg
% find radii of gyration^2 by setting solidworks model mass to 1kg
% (pay attention to solidworks MOI output coordinate system)
body(1).mass = 142.65;
body(1).inertia = body(1).mass * [0.141 0.141 0.1006];  % Moment of Inertia [kg*m^2]   
body(1).initial.displacement = [0 0 -2];
body(1).nonlinearHydro = 2;

%body.quadDrag.area = [0.0771 0.0771 pi/4*(0.305^2) 0 0.041 0] * 3.2808399^2;
body.quadDrag.area = [0 0 0 0 0 0];
body.quadDrag.cd = [1 1 1 0 1 0];

%% PTO and Constraint Parameters
% rotational joint at reaction plate
constraint(1) = constraintClass('Constraint1'); % Initialize constraintClass for Constraint1
%constraint(1).location = [0 0 -1];

% bridle at bottom of buoy
constraint(2) = constraintClass('Constraint2'); % Initialize constraintClass for Constraint1
constraint(2).location = [0 0 -0.834] + body.initial.displacement;  % Constraint Location [m]

constraint(1).location = constraint(2).location + [0 0 -10];

% Translational PTO
pto(1) = ptoClass('PTO1');                      % Initialize ptoClass for PTO1
pto(1).stiffness = 1000;%534;                                   % PTO Stiffness [N/m]
pto(1).damping = 500;                             % PTO Damping [N/(m/s)]
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