% Load the IEEE 39-bus test case
mpc = case39;

% Wind power parameters
selected_bus = 28; % Selected optimal location
capacities = 500:100:1000; % Wind farm capacities in MW (adjust as needed)
power_factor = 0.9; % Power factor for wind power

% Initialize results storage
voltage_violations = zeros(length(capacities), 1);
branch_violations = zeros(length(capacities), 1);

% Loop through increasing wind farm capacities
for i = 1:length(capacities)
    P_wind = capacities(i); % Active power
    Q_wind = P_wind * sqrt(1/power_factor^2 - 1); % Reactive power
    
    % Copy the base case
    mpc_current = mpc;
    
    % Inject wind power at the selected bus
    mpc_current.bus(selected_bus,3) = mpc_current.bus(selected_bus,3) - P_wind; % Active power
    mpc_current.bus(selected_bus,4) = mpc_current.bus(selected_bus,4) - Q_wind; % Reactive power
    
    % Run power flow simulation
    result = runpf(mpc_current);
    
    % Check for voltage violations
    V = result.bus(:,8);
    voltage_violations(i) = any(V < 0.9 | V > 1.1);
    
    % Check for branch overloads
    branch_flows = abs(result.branch(:,14));
    branch_limits = result.branch(:,6);
    branch_violations(i) = any(branch_flows > branch_limits);
    
    % Display results for this capacity
    fprintf('Wind Capacity: %d MW\n', P_wind);
    fprintf('Voltage Violations: %d\n', voltage_violations(i));
    fprintf('Branch Overloads: %d\n\n', branch_violations(i));
end

% Plot the results
figure;
subplot(2,1,1);
plot(capacities, voltage_violations, '-o', 'LineWidth', 1.5);
title('Voltage Violations vs Wind Farm Capacity');
xlabel('Wind Farm Capacity (MW)');
ylabel('Voltage Violations (1 = Yes, 0 = No)');
grid on;

subplot(2,1,2);
plot(capacities, branch_violations, '-o', 'LineWidth', 1.5);
title('Branch Overloads vs Wind Farm Capacity');
xlabel('Wind Farm Capacity (MW)');
ylabel('Branch Overloads (1 = Yes, 0 = No)');
grid on;
