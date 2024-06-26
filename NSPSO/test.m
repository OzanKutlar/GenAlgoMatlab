global parameters;
global op;
op.name = "ZDT11";
addpath('..\Shared');
benchmark(zeros(2,2), true);
swarm = ans;

parameters.particleCount = 50; % Number of particles
parameters.iterationTime = 20; % Maximum number of 'iterations' to run the simulation
%op.numberOfDecisionVar = 2;
%op.numberOfObjectives = 2;
% Set speed after position
bestPos = swarm(:, 1:op.numberOfDecisionVar);

currentPareto = bestPos(1, 1:op.numberOfDecisionVar);
currentParetoValues = benchmark(currentPareto);
bestPosVal = currentParetoValues;
% Evaluate
for i = 1:parameters.particleCount
    if i == 42
        disp("ITS TIME");
    end
    value = benchmark(swarm(i, 1:op.numberOfDecisionVar));
    bestPosVal(i, :) = value;
    dominated = false;
    %disp(i);
    for j = 1:height(currentParetoValues)
        if ~any(value >= currentParetoValues(j, :))
            currentParetoValues(j, :) = value;
            currentPareto(j, :) = swarm(i, 1:op.numberOfDecisionVar);
            dominated = true;
            removed = 0;
            for ii = 1:height(currentParetoValues)
                if ~any(value >= currentParetoValues(ii - removed, :))
                    currentParetoValues(ii - removed, :) = [];
                    removed = removed + 1;
                end
            end
            break;
        end
        if ~any(currentParetoValues(j, :) > value)
            if any(currentParetoValues(j, :) < value)
                dominated = true;
                break;
            end
        end
    end
    if ~dominated
        currentPareto(end+1, :) = swarm(i, 1:op.numberOfDecisionVar);
        currentParetoValues(end+1, :) = value(:);
    end
    clf;
    hold on
    %figure;
    scatter(bestPosVal(:, 1), bestPosVal(:, 2), 'filled','DisplayName',"Particle Swarm")
    scatter(currentParetoValues(:, 1), currentParetoValues(:, 2), 'filled','DisplayName',"Particle Swarm")
    plot(currentParetoValues(:, 1), currentParetoValues(:, 2), "-x")
    %drawnow;
    hold off
    %pause;
    legend({'Swarm', 'Pareto'});
end
