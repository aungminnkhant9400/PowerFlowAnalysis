clc

% Load the IEEE 39-bus test case
mpc = case39;

% Define reactive power compensation parameters
svc_buses = [10, 20, 30]; % Buses where SVCs will be installed
Q_comp = 50; % Reactive power compensation (MVAR)

% Add reactive power compensation
for i = 1:length(svc_buses)
    bus_idx = svc_buses(i);
    mpc.bus(bus_idx, 4) = mpc.bus(bus_idx, 4) - Q_comp; % Reduce reactive demand
    fprintf('Added %d MVAR compensation at Bus %d\n', Q_comp, bus_idx);
end

% Run power flow
result = runpf(mpc);

% Check results
V = result.bus(:,8); % Voltage magnitudes
fprintf('Voltage Magnitudes after SVC Installation:\n');
disp(array2table(V, 'VariableNames', {'Voltage_pu'}));

% Plot voltage profile
figure;
plot(1:length(V), V, '-o', 'LineWidth', 1.5);
title('Voltage Profile with Reactive Power Compensation (SVC)');
xlabel('Bus Number');
ylabel('Voltage Magnitude (p.u.)');
grid on;
