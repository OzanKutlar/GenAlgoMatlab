global parameters;
global op;
op.name = "ZDT3";
addpath('..\Shared');
% whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 20; % Number of particles
parameters.topPercentageOfDom = 10;
parameters.personalConst = 0.01;
parameters.socialConst = 0.01;
parameters.iterationTime = 400; % Maximum number of 'iterations' to run the simulation
% Set speed after position
swarm = zeros(parameters.particleCount, op.numberOfDecisionVar * 2);

for i = 1:op.numberOfDecisionVar
    swarm(:, i) = op.bounds(i, 1) + (op.bounds(i, 2)-op.bounds(i, 1)) .* rand(parameters.particleCount, 1);
end
personalBest = swarm(:, 1:op.numberOfDecisionVar);
swarmParetoCoords = zeros(parameters.particleCount, op.numberOfObjectives);
currentPareto = swarm(1, 1:op.numberOfDecisionVar);
currentParetoValues = benchmark(currentPareto);
bestPosVal = currentParetoValues;


% Converts the percentage into a float number to be multiplied later
parameters.topPercentageOfDom = parameters.topPercentageOfDom / 100;


% Evaluate
[bestPosVal, personalBest, currentPareto, currentParetoValues, swarmParetoCoords] = evaluate(swarm, parameters, op, currentPareto, currentParetoValues, bestPosVal, personalBest, swarmParetoCoords);


% Cycle
for i = 2:parameters.iterationTime
    
    swarmRanking = zeros(height(swarm), 2);
    swarmRanking(:, 2) = 1:1:height(swarm);
    for ii = 1:height(swarm)
        for iii = 1:height(currentParetoValues)
            if(any(currentParetoValues(iii, :) < swarmParetoCoords(ii, :)))
                swarmRanking(ii, 1) = swarmRanking(ii, 1) + 1;
            end
        end
    end
    
    swarmRanking = sortrows(swarmRanking, 1);
    oldPop = swarm;
    oldPB = personalBest;

    disp(i);
    % Calculate new speed
    for ii = 1:parameters.particleCount

        closestPareto = zeros(1, op.numberOfDecisionVar);
        sizeOfBest = ceil(height(swarmRanking) * parameters.topPercentageOfDom);
        randomIndex = floor(rand(1,1) * (sizeOfBest - 1)) + 1;

        % Gets the real index of the swarm from the sorted index
        randomIndex = swarmRanking(randomIndex, 2);
        closestPareto(1, :) = swarm(randomIndex, 1:op.numberOfDecisionVar);

        oldPos = swarm(ii, 1:op.numberOfDecisionVar);

        % Personal Influence
        swarm(ii, op.numberOfDecisionVar+1:end) = swarm(ii, op.numberOfDecisionVar+1:end) + parameters.personalConst*rand(1)*(personalBest(ii, :) - oldPos);

        % Social Influence
        swarm(ii, op.numberOfDecisionVar+1:end) = swarm(ii, op.numberOfDecisionVar+1:end) + parameters.socialConst*rand(1)*(closestPareto - oldPos);
        swarm(ii, 1:op.numberOfDecisionVar) = oldPos + swarm(ii, op.numberOfDecisionVar+1:end);

        newPos = swarm(ii, 1:op.numberOfDecisionVar);
        swarm(ii, 1:op.numberOfDecisionVar) = max(swarm(ii, 1:op.numberOfDecisionVar), op.bounds(1,1)); % TODO : Fix specific bounds for each value
        swarm(ii, 1:op.numberOfDecisionVar) = min(swarm(ii, 1:op.numberOfDecisionVar), op.bounds(1,2));
        if newPos ~= swarm(ii, 1:op.numberOfDecisionVar)
            swarm(ii, op.numberOfDecisionVar+1:end) = -1 * swarm(ii, op.numberOfDecisionVar+1:end);
        end
    end



    % Evaluate
    [bestPosVal, personalBest, currentPareto, currentParetoValues, swarmParetoCoords] = evaluate(swarm, parameters, op, currentPareto, currentParetoValues, bestPosVal, personalBest, swarmParetoCoords);

    combinedList = vertcat(personalBest, swarm(:, 1:op.numberOfDecisionVar));
    nonDomList = zeros(1,op.numberOfDecisionVar);
    for ii = 1:height(combinedList)
        pos = combinedList(ii, :);
        dom = true;
        for iii = 1:parameters.particleCount
            pos2 = swarm(iii, 1:op.numberOfDecisionVar);
            if all(pos2 < pos)
                dom = false;
                break;
            end
        end
        if dom
            nonDomList(end+1, :) = pos(:);
        end
    end
    nonDomList(1, :) = [];

    swarm(:, 1:op.numberOfDecisionVar) = zeros(height(swarm), op.numberOfDecisionVar);
    
    for ii = 1:parameters.particleCount
        if(height(nonDomList) == 0)
            randomIndex = floor(rand(1,1) * height(combinedList - 1)) + 1;
            swarm(ii, 1:op.numberOfDecisionVar) = combinedList(randomIndex, :);
            continue;
        end
        randomIndex = floor(rand(1,1) * height(nonDomList - 1)) + 1;
        swarm(ii, 1:op.numberOfDecisionVar) = nonDomList(randomIndex, :);
        nonDomList(randomIndex, :) = [];
    end
    

    clf;
    hold on
    %figure;
    sortedPareto = sortrows(currentParetoValues);
    if op.numberOfObjectives == 2
        scatter(bestPosVal(:, 1), bestPosVal(:, 2), 'filled','DisplayName',"Particle Swarm")
        scatter(currentParetoValues(:, 1), currentParetoValues(:, 2), 'filled','DisplayName',"Particle Swarm");
        plot(sortedPareto(:, 1), sortedPareto(:, 2), "-x")
        % scatter(currentParetoValues(:, 1), currentParetoValues(:, 2), 'filled','DisplayName',"Particle Swarm", "MarkerFaceColor","red");
        % plot(sortedPareto(:, 1), sortedPareto(:, 2), "-x", MarkerFaceColor="red", MarkerEdgeColor="red", Color="red")
    end
    if op.numberOfObjectives == 3
        scatter3(bestPosVal(:, 1),bestPosVal(:, 2), bestPosVal(:, 3),'filled');
        scatter3(currentParetoValues(:, 1),currentParetoValues(:, 2), currentParetoValues(:, 3),'filled');
        plot3(sortedPareto(:, 1), sortedPareto(:, 2), sortedPareto(:, 3), "-x")
    end
    %hold off
    legend({'Swarm', 'Pareto'});
    drawnow
end


clf;
hold on
%figure;
sortedPareto = sortrows(currentParetoValues);
if op.numberOfObjectives == 2
    scatter(currentParetoValues(:, 1), currentParetoValues(:, 2), 'filled','DisplayName',"Particle Swarm", MarkerFaceColor="red")
    %plot(sortedPareto(:, 1), sortedPareto(:, 2), "-x")
end
if op.numberOfObjectives == 3
    %scatter3(bestPosVal(:, 1),bestPosVal(:, 2), bestPosVal(:, 3),'filled','DisplayName', "Particle Swarm");
    scatter3(sortedPareto(:, 1),sortedPareto(:, 2), sortedPareto(:, 3),'filled','DisplayName', "Particle",  MarkerFaceColor="red");
    %plot3(currentParetoValues(:, 1), currentParetoValues(:, 2), currentParetoValues(:, 3), "-x")
end
hold off
legend({'Swarm', 'Pareto'});

