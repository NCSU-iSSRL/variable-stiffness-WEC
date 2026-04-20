% clc; clear all; close all;

%% hydro data
hydro = struct();
hydro = readAQWA(hydro, 'OW1_hydro.AH1', 'OW1_hydro.LIS');
hydro = radiationIRF(hydro,5,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,5,[],[],[],[]);
writeBEMIOH5(hydro)

%% Plot hydro data
plotBEMIO(hydro)
