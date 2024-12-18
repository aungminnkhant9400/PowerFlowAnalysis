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
violated_branches = cell(length(candidate_buses), 1);
total_violations = zeros(length(candidate_buses), 1);

% Step: Inject wind power and verify results
for i = 1:length(candidate_buses)
    fprintf('Analyzing Candidate Bus %d\n', candidate_buses(i));
    
    % Copy the base case
    mpc_current = mpc;
    bus_id = candidate_buses(i);

    % Inject wind power at candidate bus
    mpc_current.bus(bus_id,3) = mpc_current.bus(bus_id,3) - P_wind; % Active power
    mpc_current.bus(bus_id,4) = mpc_current.bus(bus_id,4) - Q_wind; % Reactive power
    
    % Run power flow
    result = runpf(mpc_current);
    
    % Check for branch overloads
    branch_flows = abs(result.branch(:,14)); % Real power flow (MW)
    branch_limits = result.branch(:,6); % Branch ratings (MW)
    overloads = branch_flows > branch_limits; % Logical array of overloads
    
    % Store overloaded branch IDs
    violated_branches{i} = find(overloads);
    total_violations(i) = sum(overloads);

    % Display results
    fprintf('Number of Branch Overloads: %d\n', total_violations(i));
    if total_violations(i) > 0
        fprintf('Overloaded Branches: %s\n', mat2str(violated_branches{i}));
    end
end

% Summary
fprintf('\nVerification Summary:\n');
for i = 1:length(candidate_buses)
    fprintf('Bus %d - Total Branch Overloads: %d\n', candidate_buses(i), total_violations(i));
end
