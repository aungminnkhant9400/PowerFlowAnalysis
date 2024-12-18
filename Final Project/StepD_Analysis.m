% Load the IEEE 39-bus test case
mpc = case39;

% Load daily load profile
load_profile = [0.734046740872781, 0.70591312355725, 0.694045550471347, ...
                0.673961965249051, 0.670393394321122, 0.678969029884362, ...
                0.720657684057916, 0.766357522607826, 0.848794277377033, ...
                0.97504976354034, 0.983819042487265, 0.992450004731558, ...
                0.935463523246804, 0.911285763626575, 0.915905541494513, ...
                0.945118029090581, 0.892364038706394, 0.831421699526341, ...
                0.795044406733888]; % Replace with actual data

% Define PV farm parameters
selected_bus = 28; % Optimal location for PV power
P_pv = 500; % Active power from PV (MW)
Q_pv = 0; % Assume no reactive power contribution

% Initialize storage for results
num_time_steps = length(load_profile);
V_pv = zeros(size(mpc.bus,1), num_time_steps); % Voltage magnitudes
P_flow_pv = zeros(size(mpc.branch,1), num_time_steps); % Branch power flows
voltage_violations = zeros(num_time_steps, 1);
branch_overloads = zeros(num_time_steps, 1);

% Step 1: Simulate PV integration under daily load profile
for t = 1:num_time_steps
    mpc_current = mpc; % Copy the base case
    
    % Scale load for current time step
    mpc_current.bus(:,3) = mpc.bus(:,3) * load_profile(t);
    mpc_current.bus(:,4) = mpc.bus(:,4) * load_profile(t);
    
    % Inject PV power at selected bus
    mpc_current.bus(selected_bus,3) = mpc_current.bus(selected_bus,3) - P_pv; % Active power
    mpc_current.bus(selected_bus,4) = mpc_current.bus(selected_bus,4) - Q_pv; % Reactive power

    % Run power flow simulation
    result_pv = runpf(mpc_current);

    % Store results
    V_pv(:,t) = result_pv.bus(:,8); % Voltage magnitudes
    P_flow_pv(:,t) = result_pv.branch(:,14); % Branch power flows
    
    % Check for violations
    voltage_violations(t) = any(V_pv(:,t) < 0.9 | V_pv(:,t) > 1.1);
    branch_overloads(t) = any(abs(P_flow_pv(:,t)) > result_pv.branch(:,6));
end

% Step 2: Visualization with labels and legends

% Plot voltage profiles over time
figure;
plot(V_pv', '-o', 'LineWidth', 1.5);
title('Voltage Profiles with PV Integration at Bus 28');
xlabel('Time Step');
ylabel('Voltage Magnitude (p.u.)');
legend(arrayfun(@(x) sprintf('Bus %d', x), 1:size(mpc.bus,1), 'UniformOutput', false), 'Location', 'eastoutside');
grid on;

% Plot branch power flows
figure;
plot(P_flow_pv', '-o', 'LineWidth', 1.5);
title('Branch Power Flows with PV Integration at Bus 28');
xlabel('Time Step');
ylabel('Power Flow (MW)');
legend(arrayfun(@(x) sprintf('Branch %d', x), 1:size(mpc.branch,1), 'UniformOutput', false), 'Location', 'eastoutside');
grid on;

% Display summary
fprintf('Total Time Steps with Voltage Violations: %d\n', sum(voltage_violations));
fprintf('Total Time Steps with Branch Overloads: %d\n', sum(branch_overloads));
