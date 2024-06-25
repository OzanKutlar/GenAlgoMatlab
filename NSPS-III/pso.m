global parameters;
global op;
op.name = "ZDT1";
addpath('..\Shared');
% whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 200; % Number of particles
parameters.personalConst = 2;
parameters.socialConst = 2;
parameters.iterationTime = 100; % Maximum number of 'iterations' to run the simulation
parameters.socialDistance = 1; % Distance at which particles are moved apart.

% Create a structure array to hold the particles
swarm(parameters.particleCount) = struct('position', [], 'velocity', [], 'personalBest', [], 'paretoPosition', []);

% Use a loop to initialize the particles
for i = 1:parameters.particleCount
    % Assign random values to the position, velocity, and personalBest
    swarm(i).velocity = rand(1, op.numberOfDecisionVar);
    for ii = 1:op.numberOfDecisionVar
        swarm(i).position(ii) = op.bounds(ii, 1) + (op.bounds(ii, 2)-op.bounds(ii, 1)) .* rand(1, 1);
    end
    swarm(i).velocity = rand(1, op.numberOfDecisionVar);
    swarm(i).paretoPosition = benchmark(swarm(i).position);
    swarm(i).personalBest = swarm(i);

end
clear i ii

for i = 1:parameters.iterationTime
    disp(strcat("Entering Iteration : ", num2str(i)));
    
    swarm(i).velocity = swarm(i).velocity + parameters.personalConst*(swarm(i).personalBest.position - swarm(i).position);
    swarm(i).velocity = swarm(i).velocity + parameters.socialConst*(bestP.position - swarm(i).position);
    swarm(i).position = swarm(i).position + swarm(i).velocity;

end






function pareto = getParetoSpace(swarm)
    pareto = zeros(width(swarm), width(swarm(1).paretoPosition));
    for i = 1:width(swarm)
        pareto(i, :) = swarm(i).paretoPosition;
    end
end

