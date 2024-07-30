clear;
clc;
clf;
global parameters;
global op;
op.name = "zdt1";
addpath('..\Shared');
whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 300; % Number of particles
parameters.personalConst = 0.1;
parameters.socialConst = 0.2;
parameters.iterationTime = 300; % Maximum number of 'iterations' to run the simulation
parameters.division = 4; % Amount of divisions per dimension for the reference directions
parameters.speedLimit = abs(op.bounds(1, 2) - op.bounds(1, 1));

parameters.elasticity = 0; % Bounce back speed


parameters.eliteCount = parameters.particleCount * 1;
% parameters.eliteCount = 15;

% Create a structure array to hold the particles
swarm(parameters.particleCount) = struct('position', [], 'velocity', [], 'personalBest', [], 'paretoPosition', [], 'target', []);

% Use a loop to initialize the particles
for i = 1:parameters.particleCount
    % Assign random values to the position, velocity, and personalBest
    for ii = 1:op.numberOfDecisionVar
        swarm(i).position(ii) = op.bounds(ii, 1) + (op.bounds(ii, 2)-op.bounds(ii, 1)) .* rand(1, 1);
    end
    swarm(i).velocity = (rand(1, op.numberOfDecisionVar) * 2) - 1;
    swarm(i).paretoPosition = benchmark(swarm(i).position);
    swarm(i).personalBest = swarm(i);

end
clear i ii

selectedElites(parameters.eliteCount + 1) = swarm(1);
selectedElites(parameters.eliteCount + 1) = [];
speed = 10.^-(min(linspace(0, 6, parameters.iterationTime), 1));
speed2 = 10.^-(min(linspace(0, 4, parameters.iterationTime), 2));
speed = speed(1:parameters.iterationTime);
speed2 = speed2(1:parameters.iterationTime);
for i = 1:parameters.iterationTime
    disp(strcat("Entering Iteration : ", num2str(i)));
    % parameters.personalConst = 0.1 * speed2(i);
    % parameters.socialConst = 0.2 * speed2(i);
    % parameters.speedLimit = speed(i);
    
    
    thisGenElites = getParetoSwarm(swarm);
    
    selectedElites = selectElites(thisGenElites, selectedElites);

    % Update and evaluate
    swarm = updatePositions(swarm, selectedElites);
    
    swarm = evaluate(swarm);
    
    
    displayFigure(selectedElites, swarm, horzcat(speed', speed2'), i);

end

paretoFront = getParetoSpace(selectedElites);
if(width(paretoFront) == 2)
    scatter(paretoFront(:, 1), paretoFront(:, 2), 40, 'filled');
else
    scatter3(paretoFront(:, 1), paretoFront(:, 2), paretoFront(:, 3), 40, 'filled');
end

% pareto.name = op.name;
% pareto.data = paretoFront;
% pareto.N = parameters.particleCount;
% 
% counter = 1;
% while isfile("result" + counter + ".mat")
%     counter = counter + 1;
% end
% save("result" + counter + ".mat", "pareto");


function displayFigure(elites, all, speedCurve, generation)
    pareto = getParetoSpace(all);
    pareto2 = getParetoSpace(elites);
    pareto = vertcat(pareto, pareto2);
    mu = repmat([1, 1, 1], height(pareto), 1);
    for ii = width(all) + 1:height(pareto)
        mu(ii, :) = [1, 0, 0];
    end
    
    % pareto = getParetoSpace(selectedElites);
    subplot(2, 1, 1)
    if(width(pareto) == 2)
        scatter(pareto(:, 1), pareto(:, 2), 40, mu, 'filled');
    else
        scatter3(pareto(:, 1), pareto(:, 2), pareto(:, 3), 40, mu, 'filled');
    end
    subplot(2, 1, 2)

    if(width(pareto2) == 2)
        scatter(pareto2(:, 1), pareto2(:, 2), 'filled');
    else
        scatter3(pareto2(:, 1), pareto2(:, 2), pareto2(:, 3), 'filled');
    end
    % plot(speedCurve);
    % xline(generation, '-r', 'Current Generation');
    drawnow
end


function elites = selectElites(swarm, elites)
    global parameters;
    
    newElites = horzcat(swarm, elites);
    elites = getParetoSwarm(newElites);
    eliteCount = width(elites);

    if(eliteCount > parameters.eliteCount)
        
        % Reverse niching?
        % Remove elements from the most assosiated ones...
        [normalizedSwarm, reference_directions] = doNormalize(getParetoSpace(elites(1:eliteCount)));
        assosiations = assosiate(normalizedSwarm, reference_directions, elites(1:eliteCount));

        toBeRemoved((eliteCount - parameters.eliteCount) + 1) = swarm(1);
        toBeRemoved((eliteCount - parameters.eliteCount) + 1) = [];
        while true
            if(parameters.eliteCount == eliteCount)
                break;
            end

            longestCount = assosiations(1).count;
            longestIndex = 1;
            for i = 2:width(assosiations)
                if(assosiations(i).count >= longestCount)
                    if(assosiations(i).count == longestCount && round(rand()) == 1)
                        continue;
                    end
                    longestCount = assosiations(i).count;
                    longestIndex = i;
                end
            end
            
            furthestIndex = round(rand() * (longestCount - 2)) + 1;

            % furthest = assosiations(longestIndex).swarm(1);
            % furthestIndex = 1;
            % for i = 2:longestCount
            %     if(assosiations(longestIndex).swarm(i).dist <= furthest.dist)
            %         if(assosiations(longestIndex).swarm(i).dist == furthest.dist && round(rand()) == 1)
            %             continue;
            %         end
            %         furthest = assosiations(longestIndex).swarm(i);
            %         furthestIndex = i;
            %     end
            % end

            toBeRemoved((eliteCount - parameters.eliteCount)) = assosiations(longestIndex).swarm(furthestIndex).position;
            assosiations(longestIndex).swarm(furthestIndex) = [];
            assosiations(longestIndex).count = assosiations(longestIndex).count - 1;
            eliteCount = eliteCount - 1;
        end
        clear longestCount longestIndex i randomCandidate
        removed = 0;
        for i = 1:width(elites)
            if(width(toBeRemoved) == 0)
                break;
            end
            for ii = 1:width(toBeRemoved)
                if(all(elites(i - removed).position(:) == toBeRemoved(ii).position(:)))
                    elites(i - removed) = [];
                    removed = removed + 1;
                    toBeRemoved(ii) = [];
                    break;
                end
            end
        end
    end
   
end


% Input : Particle Swarm, Elites
% Output : Particle Swarm
% Exp : Updates the swarm's velocity according to the newly selected elites
function swarm = updatePositions(swarm, elites)
    global parameters op;
    swarm(1:width(elites)) = elites;
    for i = 1:width(swarm)
        if(isempty(swarm(i).target))
            globalBest = round(rand() * (width(elites) - 1)) + 1;
            swarm(i).target = elites(globalBest);
        end
        if(abs(sum(swarm(i).position - swarm(i).target.position)) <= 0.01)
            swarm(i).target = [];
            globalBest = round(rand() * (width(elites) - 1)) + 1;
            swarm(i).target = elites(globalBest);
        end

        bestP = swarm(i).target;
        
        swarm(i).velocity = swarm(i).velocity + rand()*parameters.personalConst*(swarm(i).personalBest.position - swarm(i).position);
        swarm(i).velocity = swarm(i).velocity + rand()*parameters.socialConst*(bestP.position - swarm(i).position);
        swarm(i).velocity(:) = max(min(swarm(i).velocity(:), parameters.speedLimit), -parameters.speedLimit);
        swarm(i).position = swarm(i).position + swarm(i).velocity;
        for iii = 1:op.numberOfDecisionVar
            swarm(i).position(iii) = max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
            if (swarm(i).position(iii) ~= max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1)))
                swarm(i).position(iii) = max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
                swarm(i).velocity(iii) = -swarm(i).velocity(iii) * parameters.elasticity;
                % swarm(i).velocity = zeros(size(swarm(i).velocity));
            end
        end
    end
end

% Input : Particle Swarma
% Output : Particle Swarm
% Exp : Evaluates each swarm and updates their paretoPosition
function swarm = evaluate(swarm)
    global op
    if(startsWith(op.name, "DTLZ"))
        swarm = evaluateWholeAtOnce(swarm);
        return;
    end
    for i = 1:width(swarm)
        oldPos = swarm(i).paretoPosition;
        swarm(i).paretoPosition = benchmark(swarm(i).position);
        if(any(oldPos(:) < swarm(i).paretoPosition(:)))
            swarm(i).personalBest = swarm(i);
        end
    end
end

function swarm = evaluateWholeAtOnce(swarm)
    oldPareto = getParetoSpace(swarm);
    position = zeros(width(swarm), width(swarm(1).position));
    for i = 1:width(swarm)
        position(i, :) = swarm(i).position;
    end
    result = benchmark(position);
    for i = 1:width(swarm)
        swarm(i).paretoPosition = result(i, :);
        if(any(oldPareto(i, :) > swarm(i).paretoPosition(:)))
            swarm(i).personalBest = swarm(i);
        end
    end
end

% Input : the particle swarm
% Output : Only the non dominating values in the swarm.
function returnSwarm = getParetoSwarm(swarm)

    pareto = getParetoSpace(swarm);
    newSwarm(height(pareto) + 1) = swarm(1);
    newSwarm(height(pareto) + 1) = [];
    size = 0;
    for i = 1:width(swarm)
        particle = swarm(i).paretoPosition;
        if(isempty(particle))
            continue;
        end
        isDominated = checkDom(particle, pareto);
        if ~isDominated
            size = size + 1;
            newSwarm(size) = swarm(i);
        end
    end
    returnSwarm(1:size) = newSwarm(1:size);
end


% Input : the particle swarm
% Output : non dominating layers, each layer has an empty particle in
% between them. Can be checked using isempty
function newSwarm = getNonDominatedSwarm(swarm)
    layer = 0;
    pareto = getParetoSpace(swarm);
    originalSize = width(swarm);
    index = 1;
    while true
        newSwarm(originalSize + 1 + layer) = swarm(1);
        newSwarm(originalSize + 1 + layer) = [];
        removed = 0;
        nextSwarm = swarm;
        nextPareto = pareto;
        for i = 1:width(swarm)
            particle = swarm(i).paretoPosition;


            isDominated = checkDom(particle, pareto);
            

            if ~isDominated
                newSwarm(index) = swarm(i);
                nextSwarm(i - removed) = [];
                nextPareto(i - removed, :) = [];
                index = index + 1;
                removed = removed + 1;
            end
        end
        if(width(nextSwarm) == 0)
            break;
        end
        swarm = nextSwarm;
        pareto = nextPareto;
        layer = layer + 1;
        index = index + 1;
    end
end

% Input : single particle's pareto location, all pareto locations
% Output : Boolean, is the particle dominated by others?
function isDominated = checkDom(particle, pareto)
    isDominated = false;
    for i = 1:height(pareto)
        if(all(pareto(i, :) <= particle) && any(pareto(i, :) < particle))
        % if(all(pareto(i, :) < particle))
            isDominated = true;
            break;
        end
    end
end

% Input : Particle Swarm
% Output : All pareto locations in an array
function pareto = getParetoSpace(swarm)
    pareto = ones(width(swarm), width(swarm(1).paretoPosition)) * Inf;
    for i = 1:width(swarm)
        if(isempty(swarm(i).paretoPosition))
            continue;
        end
        pareto(i, :) = swarm(i).paretoPosition;
    end
end

