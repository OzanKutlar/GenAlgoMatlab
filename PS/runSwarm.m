global parameters;
global op;
op.name = "ZDT1";
addpath('..\Shared');
%whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 1000; % Number of particles
parameters.personalConst = 0; % Should the particle move towards its personal best?
parameters.socialConst = 2; % Should the particle move towards the pareto front?
parameters.iterationTime = 200; % Maximum number of 'iterations' to run the simulation
parameters.elasticity = 0.6; % How much of the original speed should the particle bounce off the wall with?
parameters.socialDistance = 0.01; % Distance at which particles are moved apart.

parameters.removeTooClosePareto = false; % Removes closest paretos that are over reduction limit
parameters.reduceParetoTo = 0.5 * parameters.particleCount; % Start removing pareto locations after this number.


% Set speed after position
swarm = zeros(parameters.particleCount, op.numberOfDecisionVar * 2);

% zoneCount = ceil(nthroot(parameters.particleCount, op.numberOfDecisionVar));



for i = 1:op.numberOfDecisionVar
    swarm(:, i) = op.bounds(i, 1) + (op.bounds(i, 2)-op.bounds(i, 1)) .* rand(parameters.particleCount, 1);
end
personalBest = swarm(:, 1:op.numberOfDecisionVar);
swarmParetoCoords = zeros(parameters.particleCount, op.numberOfObjectives);
currentPareto = swarm(1, 1:op.numberOfDecisionVar);
currentParetoValues = benchmark(currentPareto);
bestPosVal = currentParetoValues;
% Evaluate
for i = 1:parameters.particleCount
    value = benchmark(swarm(i, 1:op.numberOfDecisionVar));
    bestPosVal(i, :) = value;
    personalBest(i, :) = swarm(i, 1:op.numberOfDecisionVar);
    dominated = false;
    for j = 1:height(currentParetoValues)
        if ~any(value >= currentParetoValues(j, :))
            currentParetoValues(j, :) = value;
            currentPareto(j, :) = swarm(i, 1:op.numberOfDecisionVar);
            dominated = true;
            removed = 0;
            for ii = 1:height(currentParetoValues)
                if all(value <= currentParetoValues(ii - removed, :)) && any(value < currentParetoValues(ii - removed, :))
                    currentParetoValues(ii - removed, :) = [];
                    currentPareto(ii - removed, :) = [];
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
    swarmParetoCoords(i, :) = value;
end


% Cycle
for i = 2:parameters.iterationTime
    % disp(i);



    % Calculate Niche Count
    nicheCounts = zeros(height(currentPareto), 2);
    for ii = 1:height(currentPareto)
        part1 = currentParetoValues(ii, :);
        rest = currentParetoValues;
        rest = abs(rest - part1);
        rest = rest .^ 2;
        rest = sqrt(sum(rest, 2));
        rest = parameters.socialDistance > rest;
        nicheCounts(ii, 1) = sum(rest) - 1;
        nicheCounts(ii, 2) = ii;
    end

    nicheCounts = sortrows(nicheCounts);
    


    % Calculate new speed
    for ii = 1:parameters.particleCount
        
        globalBest = round(rand(1, 1) * (height(nicheCounts) * 0.3)) + 1;
        closestPareto = currentPareto(nicheCounts(globalBest, 2), :);
        
        oldPos = swarm(ii, 1:op.numberOfDecisionVar);

        % Personal Influence
        swarm(ii, op.numberOfDecisionVar+1:end) = swarm(ii, op.numberOfDecisionVar+1:end) + parameters.personalConst*rand(1)*(personalBest(ii, :) - oldPos);

        % Social Influence
        swarm(ii, op.numberOfDecisionVar+1:end) = swarm(ii, op.numberOfDecisionVar+1:end) + parameters.socialConst*rand(1)*(closestPareto - oldPos);
        swarm(ii, 1:op.numberOfDecisionVar) = oldPos + swarm(ii, op.numberOfDecisionVar+1:end);

        oldPos = swarm(ii, 1:op.numberOfDecisionVar);
        
        for iii = 1:op.numberOfDecisionVar
            swarm(ii, iii) = max(min(swarm(ii, iii), op.bounds(iii, 2)), op.bounds(iii, 1));
            % swarm(ii, op.numberOfDecisionVar+iii) = max(min(swarm(ii, op.numberOfDecisionVar+iii), op.bounds(iii, 2)), op.bounds(iii, 1));
        end

        % swarm(ii, 1:op.numberOfDecisionVar) = max(swarm(ii, 1:op.numberOfDecisionVar), op.bounds(1,1)); % TODO : Fix specific bounds for each value
        % swarm(ii, 1:op.numberOfDecisionVar) = min(swarm(ii, 1:op.numberOfDecisionVar), op.bounds(1,2));
        for iii = 1:op.numberOfDecisionVar
            if oldPos(iii) ~= swarm(ii, iii)
                swarm(ii, op.numberOfDecisionVar+iii) = -1 * swarm(ii, op.numberOfDecisionVar+iii) * parameters.elasticity;
            end
        end
        
    end

    if(parameters.removeTooClosePareto)
        if(height(nicheCounts) > parameters.reduceParetoTo)
            toBeRemoved = nicheCounts(parameters.reduceParetoTo + 1:end, 2);
            toBeRemoved = sortrows(toBeRemoved);
            removed = 0;
            for ii = 1:height(toBeRemoved)
                currentPareto(toBeRemoved(ii) - removed, :) = [];
                currentParetoValues(toBeRemoved(ii) - removed, :) = [];
                nicheCounts(end, :) = [];
                removed = removed + 1;
            end
        end
    end

    % Evaluate
    for ii = 1:parameters.particleCount
        value = benchmark(swarm(ii, 1:op.numberOfDecisionVar));
        dominated = false;
        for j = 1:height(currentParetoValues)
            if(all(value(:) >= currentParetoValues(j, :)))
                bestPosVal(ii, :) = value;
                personalBest(ii, :) = swarm(ii, 1:op.numberOfDecisionVar);
            end
            if ~any(value >= currentParetoValues(j, :))
                currentParetoValues(j, :) = value;
                currentPareto(j, :) = swarm(ii, 1:op.numberOfDecisionVar);
                dominated = true;
                removed = 0;
                for iii = 1:height(currentParetoValues)
                    if all(value <= currentParetoValues(iii - removed, :)) && any(value < currentParetoValues(iii - removed, :))
                        currentParetoValues(iii - removed, :) = [];
                        currentPareto(iii - removed, :) = [];
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
                currentPareto(end+1, :) = swarm(ii, 1:op.numberOfDecisionVar);
                currentParetoValues(end+1, :) = value(:);
        end
        swarmParetoCoords(ii, :) = value;
    end

    
    
    % [bestPosVal, personalBest, currentPareto, currentParetoValues, swarmParetoCoords] = evaluate(swarm, parameters, op, currentPareto, currentParetoValues, bestPosVal, personalBest, swarmParetoCoords);

    clf;
    hold on
    %figure;
    sortedPareto = sortrows(currentParetoValues);
    if op.numberOfObjectives == 2
        scatter(swarmParetoCoords(:, 1), swarmParetoCoords(:, 2), 'filled','DisplayName',"Particle Swarm")
        scatter(currentParetoValues(:, 1), currentParetoValues(:, 2), 'filled','DisplayName',"Particle Swarm");
        plot(sortedPareto(:, 1), sortedPareto(:, 2), "-x")

        % scatter(swarm(:, 1), swarm(:, 2), 'filled','DisplayName',"Particle Swarm")
    end
    if op.numberOfObjectives == 3
        scatter3(swarmParetoCoords(:, 1),swarmParetoCoords(:, 2), swarmParetoCoords(:, 3),'filled');
        scatter3(currentParetoValues(:, 1),currentParetoValues(:, 2), currentParetoValues(:, 3),'filled');
        plot3(sortedPareto(:, 1), sortedPareto(:, 2), sortedPareto(:, 3), "-x")
    end
    %hold off
    legend({strcat("Swarm Gen : ", num2str(i)), 'Pareto'});
    drawnow
end


clf;
hold on
%figure;
sortedPareto = sortrows(currentParetoValues);
if op.numberOfObjectives == 2
    % scatter(swarmParetoCoords(:, 1), swarmParetoCoords(:, 2), 'filled','DisplayName',"Particle Swarm")
    scatter(currentParetoValues(:, 1), currentParetoValues(:, 2), 'filled','DisplayName',"Particle Swarm", MarkerFaceColor="red")
    legend({'Swarm'});
    %plot(sortedPareto(:, 1), sortedPareto(:, 2), "-x")
    % legend({'Swarm', 'Pareto'});
end
if op.numberOfObjectives == 3
    %scatter3(bestPosVal(:, 1),bestPosVal(:, 2), bestPosVal(:, 3),'filled','DisplayName', "Particle Swarm");
    scatter3(sortedPareto(:, 1),sortedPareto(:, 2), sortedPareto(:, 3),'filled','DisplayName', "Particle",  MarkerFaceColor="red");
    %plot3(currentParetoValues(:, 1), currentParetoValues(:, 2), currentParetoValues(:, 3), "-x")
end
hold off
