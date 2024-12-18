% Load the IEEE 39-bus test case
mpc = case39;

% Define renewable power parameters
capacity_steps = 100; % Incremental step size (MW)
max_capacity = 1500; % Upper limit of renewable power to test
power_factor = 0.9; % Power factor for wind power, Q calculated
renewable_type = 'PV'; % 'Wind' or 'PV'

% Initialize results storage
num_buses = size(mpc.bus, 1);
max_safe_capacity = zeros(num_buses, 1); % Store maximum safe capacity for each bus

% Loop through each bus
for bus = 1:num_buses
    if mpc.bus(bus,2) == 3 % Skip slack bus
        continue; 
    end

    fprintf('Analyzing Bus %d\n', bus);
    safe_capacity = 0;

    for P_inj = capacity_steps:capacity_steps:max_capacity
        % Copy the base case
        mpc_current = mpc;

        % Inject active and reactive power
        mpc_current.bus(bus,3) = mpc_current.bus(bus,3) - P_inj; % Active power
        if strcmp(renewable_type, 'Wind')
            Q_inj = P_inj * sqrt(1/power_factor^2 - 1);
        else
            Q_inj = 0; % PV provides no reactive power
        end
        mpc_current.bus(bus,4) = mpc_current.bus(bus,4) - Q_inj; % Reactive power

        % Run power flow
        result = runpf(mpc_current);

        % Check for violations
        V = result.bus(:,8);
        branch_flows = abs(result.branch(:,14));
        branch_limits = result.branch(:,6);

        voltage_violation = any(V < 0.9 | V > 1.1);
        branch_violation = any(branch_flows > branch_limits);

        % If no violations, update safe capacity
        if ~voltage_violation && ~branch_violation
            safe_capacity = P_inj;
        else
            break; % Stop if violations occur
        end
    end

    % Store the maximum safe capacity for the bus
    max_safe_capacity(bus) = safe_capacity;
    fprintf('Maximum Safe Capacity at Bus %d: %d MW\n', bus, safe_capacity);
end

% Display results
fprintf('\nSummary of Maximum Safe Capacities:\n');
for bus = 1:num_buses
    if max_safe_capacity(bus) > 0
        fprintf('Bus %d: %d MW\n', bus, max_safe_capacity(bus));
    end
end

% Plot the results
figure;
bar(max_safe_capacity);
title('Maximum Renewable Energy Capacity at Each Bus');
xlabel('Bus Number');
ylabel('Maximum Capacity (MW)');
grid on;
