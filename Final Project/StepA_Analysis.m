% Load the IEEE 39-bus test case
mpc = case39; % Ensure MATPOWER's 'case39' is installed and accessible

% Load the normalized daily load profile
load_profile = [0.734046740872781, 0.70591312355725, 0.694045550471347, ...
                0.673961965249051, 0.670393394321122, 0.678969029884362, ...
                0.720657684057916, 0.766357522607826, 0.848794277377033, ...
                0.97504976354034, 0.983819042487265, 0.992450004731558, ...
                0.935463523246804, 0.911285763626575, 0.915905541494513, ...
                0.945118029090581, 0.892364038706394, 0.831421699526341, ...
                0.795044406733888]; % Replace with actual data if necessary

% Extract base load data from the network
P_base = mpc.bus(:,3); % Base active power demand (Pd)
Q_base = mpc.bus(:,4); % Base reactive power demand (Qd)

% Number of time steps
time_steps = length(load_profile);

% Initialize storage for results
V_bus_day = zeros(size(mpc.bus,1), time_steps); % Voltage magnitudes
P_flow_day = zeros(size(mpc.branch,1), time_steps); % Branch power flows

% Initialize safety violation flags
voltage_violations = zeros(size(mpc.bus,1), time_steps);
branch_violations = zeros(size(mpc.branch,1), time_steps);

% Loop through each time step to modify loads and run power flow
for t = 1:time_steps
    % Scale loads for current time step
    mpc.bus(:,3) = P_base * load_profile(t); % Active power
    mpc.bus(:,4) = Q_base * load_profile(t); % Reactive power

    % Run power flow simulation
    result = runpf(mpc);

    % Store results
    V_bus_day(:,t) = result.bus(:,8); % Voltage magnitudes
    P_flow_day(:,t) = result.branch(:,14); % Branch active power flows

    % Check for voltage violations
    voltage_violations(:,t) = (result.bus(:,8) < 0.9) | (result.bus(:,8) > 1.1);

    % Check for branch power flow violations
    branch_violations(:,t) = abs(result.branch(:,14)) > result.branch(:,6);
end

% Plot voltage profiles over time
figure;
plot(V_bus_day');
title('Voltage Profiles Over Time');
xlabel('Time Step');
ylabel('Voltage Magnitude (p.u.)');
legend(arrayfun(@(x) sprintf('Bus %d', x), 1:size(mpc.bus,1), 'UniformOutput', false));

% Plot branch power flows over time
figure;
plot(P_flow_day');
title('Branch Power Flows Over Time');
xlabel('Time Step');
ylabel('Power Flow (MW)');
legend(arrayfun(@(x) sprintf('Branch %d', x), 1:size(mpc.branch,1), 'UniformOutput', false));

% Display violation summary
disp('Voltage Violations (Per Bus, Per Time Step):');
disp(voltage_violations);

disp('Branch Power Flow Violations (Per Branch, Per Time Step):');
disp(branch_violations);
