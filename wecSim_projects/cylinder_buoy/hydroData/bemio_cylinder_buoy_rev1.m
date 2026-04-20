% clc; clear all; close all;

%% hydro data
hydro = struct();
hydro = readAQWA(hydro, 'cylinder_buoy_rev1.AH1', 'cylinder_buoy_rev1.LIS');
hydro = radiationIRF(hydro,5,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,5,[],[],[],[]);
writeBEMIOH5(hydro)

%% Plot hydro data
plotBEMIO(hydro)
