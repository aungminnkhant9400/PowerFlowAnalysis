% Load the IEEE 39-bus test case
mpc = case39;

% Wind power parameters
candidate_buses = [32, 14, 28];
P_wind = 500; % Active power (MW)
Q_wind = P_wind * sqrt(1/0.9^2 - 1); % Reactive power

% Initialize storage
voltage_profiles = cell(length(candidate_buses), 1);
branch_flows = cell(length(candidate_buses), 1);
total_violations = zeros(length(candidate_buses), 1);
overloaded_branches = cell(length(candidate_buses), 1);

% Loop for each candidate bus
for i = 1:length(candidate_buses)
    mpc_current = mpc;
    bus_id = candidate_buses(i);

    % Inject wind power at candidate bus
    mpc_current.bus(bus_id,3) = mpc_current.bus(bus_id,3) - P_wind; % Active power
    mpc_current.bus(bus_id,4) = mpc_current.bus(bus_id,4) - Q_wind; % Reactive power

    % Run power flow
    result = runpf(mpc_current);

    % Store voltage profile
    voltage_profiles{i} = result.bus(:,8);

    % Store branch power flows and violations
    branch_flows{i} = result.branch(:,14);
    overloaded = abs(result.branch(:,14)) > result.branch(:,6);
    total_violations(i) = sum(overloaded);
    overloaded_branches{i} = find(overloaded);
end

% Plot Voltage Profiles
figure;
hold on;
for i = 1:length(candidate_buses)
    plot(voltage_profiles{i}, '-o', 'LineWidth', 1.5);
end
title('Voltage Profiles for Candidate Buses');
xlabel('Bus Number');
ylabel('Voltage Magnitude (p.u.)');
legend(arrayfun(@(x) sprintf('Bus %d', x), candidate_buses, 'UniformOutput', false));
grid on;
hold off;

% Plot Overloaded Branch Flows
figure;
hold on;
for i = 1:length(candidate_buses)
    overloaded_ids = overloaded_branches{i};
    plot(overloaded_ids, branch_flows{i}(overloaded_ids), 'o-', 'LineWidth', 1.5);
end
title('Overloaded Branch Power Flows');
xlabel('Branch ID');
ylabel('Power Flow (MW)');
legend(arrayfun(@(x) sprintf('Bus %d', x), candidate_buses, 'UniformOutput', false));
grid on;
hold off;

% Bar Chart: Number of Overloaded Branches
figure;
bar(total_violations);
title('Number of Branch Overloads at Each Candidate Location');
set(gca, 'XTickLabel', arrayfun(@(x) sprintf('Bus %d', x), candidate_buses, 'UniformOutput', false));
ylabel('Number of Overloaded Branches');
grid on;
