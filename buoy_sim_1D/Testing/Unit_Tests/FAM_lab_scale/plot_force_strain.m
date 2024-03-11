totalForce = get(out.logsout, 'FAM_force');
FAM_mesh_force = get(out.logsout, 'FAM_mesh_force');
FAM_bladder_force = get(out.logsout, 'FAM_bladder_force');
strain = get(out.logsout, 'FAM_strain');

figure(1)
clf
plot(strain.Values.Data, totalForce.Values.Data, 'DisplayName', 'Total force')
title('FAM pressure = 0.0 kPa')
xlabel('Strain (m/m)')
ylabel('Force (N)')
hold on
plot(strain.Values.Data, FAM_mesh_force.Values.Data, 'DisplayName', 'FAM mesh force')
plot(strain.Values.Data, FAM_bladder_force.Values.Data, 'DisplayName', 'FAM bladder force')
legend()