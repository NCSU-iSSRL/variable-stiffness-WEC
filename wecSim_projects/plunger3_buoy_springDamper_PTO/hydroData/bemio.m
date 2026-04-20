% clc; clear all; close all;

%% hydro data
hydro = struct();
hydro = readAQWA(hydro, 'plunger3.AH1', 'plunger3.LIS');
hydro = radiationIRF(hydro,5,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,5,[],[],[],[]);
writeBEMIOH5(hydro)

%% Plot hydro data
% plotBEMIO(hydro)
