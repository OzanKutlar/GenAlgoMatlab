function [bestPosVal, personalBest, currentPareto, currentParetoValues, swarmParetoCoords] = evaluate(swarm, parameters, op, currentPareto, currentParetoValues, bestPosVal, personalBest, swarmParetoCoords)
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
        swarmParetoCoords(i, :) = value;
    end
end
