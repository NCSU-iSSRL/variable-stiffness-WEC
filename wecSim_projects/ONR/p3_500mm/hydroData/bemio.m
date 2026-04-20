% clc; clear all; close all;

%% hydro data
hydro = struct();
hydro = readAQWA(hydro, 'p3_500.AH1', 'p3_500.LIS');
hydro = radiationIRF(hydro,5,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,5,[],[],[],[]);
writeBEMIOH5(hydro)

%% Plot hydro data
% plotBEMIO(hydro)
