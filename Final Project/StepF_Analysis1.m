% Load the IEEE 39-bus test case
mpc = case39;

% Define renewable power parameters
total_renewable = 1500; % Total renewable energy capacity (MW)
num_buses = 5; % Number of buses for distributed integration
renewable_buses = [5, 6, 7, 8, 28]; % Selected buses for renewable integration

% Calculate power injection per bus
P_renewable = total_renewable / num_buses;

% Inject renewable power
for i = 1:length(renewable_buses)
    bus_idx = renewable_buses(i);
    mpc.bus(bus_idx, 3) = mpc.bus(bus_idx, 3) - P_renewable; % Active power injection
    fprintf('Injected %.2f MW at Bus %d\n', P_renewable, bus_idx);
end

% Run power flow
result = runpf(mpc);

% Check results
P_flow = result.branch(:,14); % Branch power flows
V = result.bus(:,8); % Voltage magnitudes

% Display results
fprintf('Voltage Magnitudes after Distributed Integration:\n');
disp(array2table(V, 'VariableNames', {'Voltage_pu'}));

% Plot voltage profile
figure;
plot(1:length(V), V, '-o', 'LineWidth', 1.5);
title('Voltage Profile with Distributed Renewable Integration');
xlabel('Bus Number');
ylabel('Voltage Magnitude (p.u.)');
grid on;

% Plot branch power flows
figure;
bar(abs(P_flow));
title('Branch Power Flows with Distributed Renewable Integration');
xlabel('Branch Number');
ylabel('Power Flow (MW)');
grid on;
