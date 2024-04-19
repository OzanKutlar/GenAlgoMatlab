function currentParetoValues = runSwarm()
    global parameters;
    global op;
    op.name = "ZDT1";
    addpath('..\Shared');
    whitebg("black");
    benchmark(zeros(2,2), true);
    op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

    parameters.particleCount = 20; % Number of particles
    parameters.personalConst = 0.01;
    parameters.socialConst = 0.01;
    parameters.iterationTime = 400; % Maximum number of 'iterations' to run the simulation
    % Set speed after position
    swarm = zeros(parameters.particleCount, op.numberOfDecisionVar * 2);

    % zoneCount = ceil(sqrt(parameters.particleCount));
    % index1 = 1;
    % for i = op.bounds(2, 1):(op.bounds(2, 2)-op.bounds(2, 1))/zoneCount:op.bounds(2,2)
    %     index2 = 1;
    %     for ii = op.bounds(1, 1):(op.bounds(1, 2)-op.bounds(1, 1))/zoneCount:op.bounds(1,2)
    %         swarm(index1+index2, 1:op.numberOfDecisionVar) = [i, ii];
    %         index2 = index2 + 1;
    %     end
    %     index1 = index2 + 1;
    % end
    

    for i = 1:op.numberOfDecisionVar
        swarm(:, i) = op.bounds(i, 1) + (op.bounds(i, 2)-op.bounds(i, 1)) .* rand(parameters.particleCount, 1);
    end
    personalBest = swarm(:, 1:op.numberOfDecisionVar);
    swarmParetoCoords = zeros(parameters.particleCount, op.numberOfObjectives);
    currentPareto = swarm(1, 1:op.numberOfDecisionVar);
    currentParetoValues = benchmark(currentPareto);
    bestPosVal = currentParetoValues;
    % Evaluate
    [bestPosVal, personalBest, currentPareto, currentParetoValues, swarmParetoCoords] = evaluate(swarm, parameters, op, currentPareto, currentParetoValues, bestPosVal, personalBest, swarmParetoCoords);


    % Cycle
    for i = 2:parameters.iterationTime
        disp(i);
        % Calculate new speed
        for ii = 1:parameters.particleCount

            closestPareto = zeros(1,2);
            closestDist = -1;
            for iii = 1:height(currentParetoValues)
                distToPareto = sum(currentParetoValues(iii, :) - swarmParetoCoords(ii, :));
                if closestDist == -1 || closestDist > distToPareto
                    closestDist = distToPareto;
                    closestPareto = currentPareto(iii, :);
                end
            end
            
            oldPos = swarm(ii, 1:op.numberOfDecisionVar);

            % Personal Influence
            swarm(ii, op.numberOfDecisionVar+1:end) = swarm(ii, op.numberOfDecisionVar+1:end) + parameters.personalConst*rand(1)*(personalBest(ii, :) - oldPos);

            % Social Influence
            swarm(ii, op.numberOfDecisionVar+1:end) = swarm(ii, op.numberOfDecisionVar+1:end) + parameters.socialConst*rand(1)*(closestPareto - oldPos);
            swarm(ii, 1:op.numberOfDecisionVar) = oldPos + swarm(ii, op.numberOfDecisionVar+1:end);

            oldPos = swarm(ii, 1:op.numberOfDecisionVar);
            swarm(ii, 1:op.numberOfDecisionVar) = max(swarm(ii, 1:op.numberOfDecisionVar), op.bounds(1,1)); % TODO : Fix specific bounds for each value
            swarm(ii, 1:op.numberOfDecisionVar) = min(swarm(ii, 1:op.numberOfDecisionVar), op.bounds(1,2));
            if oldPos ~= swarm(ii, 1:op.numberOfDecisionVar)
                swarm(ii, op.numberOfDecisionVar+1:end) = -1 * swarm(ii, op.numberOfDecisionVar+1:end);
            end
        end



        % Evaluate
        % for i = 1:parameters.particleCount
        %     value = benchmark(swarm(i, 1:op.numberOfDecisionVar));
        %     bestPosVal(i, :) = value;
        %     personalBest(i, :) = swarm(i, 1:op.numberOfDecisionVar);
        %     dominated = false;
        %     for j = 1:height(currentParetoValues)
        %         if ~any(value >= currentParetoValues(j, :))
        %             currentParetoValues(j, :) = value;
        %             currentPareto(j, :) = swarm(i, 1:op.numberOfDecisionVar);
        %             dominated = true;
        %             removed = 0;
        %             for ii = 1:height(currentParetoValues)
        %                 if ~any(value >= currentParetoValues(ii - removed, :))
        %                     currentParetoValues(ii - removed, :) = [];
        %                     removed = removed + 1;
        %                 end
        %             end
        %             break;
        %         end
        %         if ~any(currentParetoValues(j, :) > value)
        %             if any(currentParetoValues(j, :) < value)
        %                 dominated = true;
        %                 break;
        %             end
        %         end
        %     end
        %     if ~dominated
        %             currentPareto(end+1, :) = swarm(i, 1:op.numberOfDecisionVar);
        %             currentParetoValues(end+1, :) = value(:);
        %     end
        %     swarmParetoCoords(i, :) = value;
        % end
        % 
        
        
        [bestPosVal, personalBest, currentPareto, currentParetoValues, swarmParetoCoords] = evaluate(swarm, parameters, op, currentPareto, currentParetoValues, bestPosVal, personalBest, swarmParetoCoords);

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
    
end