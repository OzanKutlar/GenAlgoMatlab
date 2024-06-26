clear
global parameters;
global op;
op.name = "DTLZ1";
addpath('..\Shared');
% whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 500; % Number of particles
parameters.personalConst = 2;
parameters.socialConst = 4;
parameters.iterationTime = 30000; % Maximum number of 'iterations' to run the simulation
parameters.division = 5; % Amount of divisions per dimension for the reference directions


parameters.eliteCount = parameters.particleCount * 0.1; % 10% of the population as elites by default

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

selectedElites(parameters.eliteCount + 1) = swarm(1);
selectedElites(parameters.eliteCount + 1) = [];
for i = 1:parameters.iterationTime
    disp(strcat("Entering Iteration : ", num2str(i)));
    
    
    nonDomLayers = getNonDominatedSwarm(swarm);
    
    % Select elites from the non-dominated solutions
    
    selectedElites = selectElites(nonDomLayers, selectedElites);

    % Update and evaluate
    swarm = updatePositions(swarm, selectedElites);
    
    swarm = evaluate(swarm);

    


    % pareto = getParetoSpace(swarm);
    pareto = getParetoSpace(selectedElites);

    scatter3(pareto(:, 1), pareto(:, 2), pareto(:, 3), 'filled');

    clear pareto
    drawnow

end


function elites = selectElites(nonDomLayers, elites)
    global parameters;
    selectedEliteCount = 0;
    index = 1;
    while true
        layersize = 0;
        for ii = index:width(nonDomLayers)
            if(isempty(nonDomLayers(ii).paretoPosition))
                break;
            end
            layersize = layersize + 1;
        end
        if(layersize + selectedEliteCount >= parameters.eliteCount)
            if(layersize + selectedEliteCount ~= parameters.eliteCount)
                elites = doNiching(elites, nonDomLayers(index:index+(layersize - 1)), selectedEliteCount);
            end
            break;
        end
        for iii = index:index+(layersize - 1)
            elites(selectedEliteCount + 1) = nonDomLayers(iii);
            selectedEliteCount = selectedEliteCount + 1;
            if(selectedEliteCount >= parameters.eliteCount) 
                break;
            end
        end
        if(selectedEliteCount >= parameters.eliteCount) 
            break;
        end
    
        index = ii + 1;
    end
end

function elites = doNiching(elites, nonDomLayers, eliteCount)
    global parameters;
    [normalizedSwarm, reference_directions] = doNormalize(getParetoSpace(nonDomLayers));
    assosiations = assosiate(normalizedSwarm, reference_directions, nonDomLayers);
    if(width(assosiations) == 0)
        disp("Error?");
    end
    while true
        shortest = assosiations(1);
        shortestIndex = 1;
        for i = 2:width(assosiations)
            if(assosiations(i).count <= shortest.count && assosiations(i).count ~= 0)
                shortest = assosiations(i);
                shortestIndex = i;
            end
        end
        assosiations(shortestIndex) = [];
        clear shortestIndex
        for i = 1:(parameters.eliteCount - eliteCount)
            if(shortest.count == 1)
                break;
            end
            randomCandidate = round(rand() * (shortest.count - 1)) + 1;
            if(isempty(shortest.swarm(randomCandidate).position))
                randomCandidate = round(rand() * (shortest.count - 2)) + 1;
            end
            elites(eliteCount + 1) = shortest.swarm(randomCandidate);
            shortest.swarm(randomCandidate) = [];
            shortest.count = shortest.count - 1;
            eliteCount = eliteCount + 1;
        end
        if(parameters.eliteCount == eliteCount)
            break;
        end
    end
end


% Input : Particle Swarm, Elites
% Output : Particle Swarm
% Exp : Updates the swarm's velocity according to the newly selected elites
function swarm = updatePositions(swarm, elites)
    global parameters op;
    for i = 1:width(swarm)
        globalBest = round(rand() * (width(elites) - 1)) + 1;
        bestP = elites(globalBest);
        swarm(i).velocity = swarm(i).velocity + parameters.personalConst*(swarm(i).personalBest.position - swarm(i).position);
        swarm(i).velocity = swarm(i).velocity + parameters.socialConst*(bestP.position - swarm(i).position);
        swarm(i).position = swarm(i).position + swarm(i).velocity;

        for iii = 1:op.numberOfDecisionVar
            swarm(i).position(iii) = max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
            swarm(i).velocity(iii) = max(min(swarm(i).velocity(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
        end
    end
end

% Input : Particle Swarma
% Output : Particle Swarm
% Exp : Evaluates each swarm and updates their paretoPosition
function swarm = evaluate(swarm)
    for i = 1:width(swarm)
        swarm(i).paretoPosition = benchmark(swarm(i).position);
    end
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
            % @ge asks if any of them are greater or equal
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
            isDominated = true;
            break;
        end
    end
end

% Input : Particle Swarm
% Output : All pareto locations in an array
function pareto = getParetoSpace(swarm)
    pareto = zeros(width(swarm), width(swarm(1).paretoPosition));
    for i = 1:width(swarm)
        pareto(i, :) = swarm(i).paretoPosition;
    end
end

