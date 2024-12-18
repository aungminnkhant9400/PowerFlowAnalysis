% Load the IEEE 39-bus test case
mpc = case39;

% Load the provided normalized daily load profile
load_profile = [0.734046740872781, 0.70591312355725, 0.694045550471347, ...
                0.673961965249051, 0.670393394321122, 0.678969029884362, ...
                0.720657684057916, 0.766357522607826, 0.848794277377033, ...
                0.97504976354034, 0.983819042487265, 0.992450004731558, ...
                0.935463523246804, 0.911285763626575, 0.915905541494513, ...
                0.945118029090581, 0.892364038706394, 0.831421699526341, ...
                0.795044406733888]; % Replace with actual load profile data

% Wind power parameters
candidate_buses = [32, 14, 28]; % Buses to analyze
P_wind = 500; % Active power (MW)
Q_wind = P_wind * sqrt(1/0.9^2 - 1); % Reactive power for power factor 0.9

% Initialize results storage
V_results = cell(length(candidate_buses), length(load_profile));
P_flow_results = cell(length(candidate_buses), length(load_profile));
violations = struct('voltage', {}, 'branch', {});

% Step 1: Simulate power flow distribution under varying daily loads
for i = 1:length(candidate_buses)
    fprintf('Simulating for Candidate Bus %d\n', candidate_buses(i));
    
    % Copy the base case
    mpc_current = mpc;
    
    % Inject wind power at the candidate bus
    bus_id = candidate_buses(i);
    for t = 1:length(load_profile)
        % Scale the load based on load profile
        mpc_current.bus(:,3) = mpc.bus(:,3) * load_profile(t);
        mpc_current.bus(:,4) = mpc.bus(:,4) * load_profile(t);

        % Inject wind power (negative for generation)
        mpc_current.bus(bus_id,3) = mpc_current.bus(bus_id,3) - P_wind;
        mpc_current.bus(bus_id,4) = mpc_current.bus(bus_id,4) - Q_wind;

        % Run power flow
        result = runpf(mpc_current);

        % Store voltage and branch power flow results
        V_results{i, t} = result.bus(:,8); % Voltage magnitudes
        P_flow_results{i, t} = result.branch(:,14); % Branch power flows

        % Step 3: Check for violations
        voltage_violation = (result.bus(:,8) < 0.9) | (result.bus(:,8) > 1.1);
        branch_violation = abs(result.branch(:,14)) > result.branch(:,6);

        % Save violations
        violations(i).voltage(t) = any(voltage_violation);
        violations(i).branch(t) = any(branch_violation);
    end
end

% Display summary of violations
for i = 1:length(candidate_buses)
    fprintf('Results for Bus %d:\n', candidate_buses(i));
    fprintf('Number of Voltage Violations: %d\n', sum(violations(i).voltage));
    fprintf('Number of Branch Overloads: %d\n\n', sum(violations(i).branch));
end
