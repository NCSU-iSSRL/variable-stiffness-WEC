% clc; clear all; close all;

%% hydro data
hydro = struct();
hydro = readAQWA(hydro, 'csi_cyl.AH1', 'csi_cyl.LIS');
hydro = radiationIRF(hydro,5,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,5,[],[],[],[]);
writeBEMIOH5(hydro)

%% Plot hydro data
% plotBEMIO(hydro)
