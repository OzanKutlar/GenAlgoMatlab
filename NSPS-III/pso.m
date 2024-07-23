global parameters;
global op;
op.name = "ZDT4";
addpath('..\Shared');
% whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 100; % Number of particles
parameters.personalConst = 0.1;
parameters.socialConst = 0.2;
parameters.iterationTime = 200; % Maximum number of 'iterations' to run the simulation
parameters.division = 3; % Amount of divisions per dimension for the reference directions

parameters.elasticity = 0; % Bounce back speed


parameters.eliteCount = parameters.particleCount * 0.5; % 10% of the population as elites by default

% Create a structure array to hold the particles
swarm(parameters.particleCount) = struct('position', [], 'velocity', [], 'personalBest', [], 'paretoPosition', []);

% Use a loop to initialize the particles
for i = 1:parameters.particleCount
    % Assign random values to the position, velocity, and personalBest
    for ii = 1:op.numberOfDecisionVar
        swarm(i).position(ii) = op.bounds(ii, 1) + (op.bounds(ii, 2)-op.bounds(ii, 1)) .* rand(1, 1);
    end
    swarm(i).velocity = zeros(1, op.numberOfDecisionVar);
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

    


    pareto = getParetoSpace(swarm);
    pareto2 = getParetoSpace(getParetoSwarm(selectedElites));
    pareto = vertcat(pareto, pareto2);
    mu = repmat([1, 1, 1], height(pareto), 1);
    for ii = width(swarm) + 1:height(pareto)
        mu(ii, :) = [0, 1, 1];
    end

    % pareto = getParetoSpace(selectedElites);
    
    if(width(pareto) == 2)
        scatter(pareto(:, 1), pareto(:, 2), 40, mu, 'filled');
    else
        scatter3(pareto(:, 1), pareto(:, 2), pareto(:, 3), 40, mu, 'filled');
    end
    clear pareto pareto2
    drawnow

end

paretoFront = getParetoSpace(getParetoSwarm(selectedElites));
if(width(paretoFront) == 2)
    scatter(paretoFront(:, 1), paretoFront(:, 2), 40, 'filled');
else
    scatter3(paretoFront(:, 1), paretoFront(:, 2), paretoFront(:, 3), 40, 'filled');
end


% paretoFront = runAlgo();

pareto.name = op.name;
pareto.data = paretoFront;
pareto.N = parameters.eliteCount;

counter = 1;
while isfile("result" + counter + ".mat")
    counter = counter + 1;
end
save("result" + counter + ".mat", "pareto");



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

    % Edgecase : The first non-dom layer comes to niching
    if(eliteCount == 0)
        [normalizedNonDom, reference_directions] = doNormalize(getParetoSpace(nonDomLayers));
        assosiations = assosiate(normalizedNonDom, reference_directions, nonDomLayers);
        while true
            if(eliteCount == parameters.eliteCount)
                break;
            end

            shortest = assosiations(1);
            shortestIndex = 1;
            for i = 2:width(assosiations)
                if(assosiations(i).count <= shortest.count && assosiations(i).count ~= 0)
                    if(assosiations(i).count == shortest.count && round(rand()) == 1)
                        continue;
                    end
                    shortest = assosiations(i);
                    shortestIndex = i;
                end
            end

            assosiations(shortestIndex) = [];
            for i = 1:shortest.count - 1
                if(eliteCount == parameters.eliteCount)
                    break;
                end
                elites(eliteCount + 1) = shortest.swarm(i);
                eliteCount = eliteCount + 1;
            end

        end
        return;
    end

    [normalizedSwarm, reference_directions] = doNormalize(getParetoSpace(elites(1:eliteCount)));
    assosiations = assosiate(normalizedSwarm, reference_directions, elites(1:eliteCount));
    [normalizedNonDom, reference_directions] = doNormalize(getParetoSpace(nonDomLayers));
    assosiationsNonDom = assosiate(normalizedNonDom, reference_directions, nonDomLayers);
    if(width(assosiations) == 0)
        disp("Error?");
    end
    while true
        if(parameters.eliteCount == eliteCount)
            break;
        end
        shortest = assosiations(1);
        shortestIndex = 1;
        for i = 2:width(assosiations)
            if(assosiations(i).count <= shortest.count)
                if(assosiations(i).count == shortest.count && round(rand()) == 1)
                    continue;
                end
                shortest = assosiations(i);
                shortestIndex = i;
            end
        end
        selected = assosiationsNonDom(shortestIndex);

        if(shortest.count == 0)
            if(selected.count == 0)
                shortest.count = Inf;
                assosiations(shortestIndex) = shortest;
                continue;
            end
        end

        if(selected.count <= 1)
            shortest.count = Inf;
            shortest.count = Inf;
            assosiations(shortestIndex) = shortest;
            continue;
        end

        randomCandidate = min(ceil(rand() * (selected.count - 1)) + 1, (selected.count - 1));
        elites(eliteCount + 1) = selected.swarm(randomCandidate);
        if(isempty(elites(eliteCount + 1).position))
            disp("ERROR");
        end
        eliteCount = eliteCount + 1;

        shortest.count = shortest.count + 1;
        selected.count = selected.count - 1;
        selected.swarm(randomCandidate) = [];

        assosiations(shortestIndex) = shortest;
        assosiationsNonDom(shortestIndex) = selected;
    end
end


% Input : Particle Swarm, Elites
% Output : Particle Swarm
% Exp : Updates the swarm's velocity according to the newly selected elites
function swarm = updatePositions(swarm, elites)
    global parameters op;
    for i = 1:width(swarm)

        isElite = false;
        for ii = 1:width(elites)
            if(all(swarm(i).position == elites(ii).position) && all(swarm(i).velocity == elites(ii).velocity))
                isElite = true;
                eliteParticle = elites(ii);
                break;
            end
        end

        if(isElite)
            continue;
        end
        globalBest = floor(rand() * (width(elites) - 1)) + 1;
        bestP = elites(globalBest);
        swarm(i).velocity = swarm(i).velocity + parameters.personalConst*(swarm(i).personalBest.position - swarm(i).position);
        swarm(i).velocity = swarm(i).velocity + parameters.socialConst*(bestP.position - swarm(i).position);
        swarm(i).position = swarm(i).position + swarm(i).velocity;
        
        for iii = 1:op.numberOfDecisionVar
            swarm(i).position(iii) = max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
            if (swarm(i).position(iii) ~= max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1)))
                swarm(i).position(iii) = max(min(swarm(i).position(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
                swarm(i).velocity(iii) = -swarm(i).velocity(iii) * parameters.elasticity;
            end
            % swarm(i).velocity(iii) = max(min(swarm(i).velocity(iii), op.bounds(iii, 2)), op.bounds(iii, 1));
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
    pareto = zeros(width(swarm), width(swarm(1).paretoPosition));
    for i = 1:width(swarm)
        if(isempty(swarm(i).paretoPosition))
            break;
        end
        pareto(i, :) = swarm(i).paretoPosition;
    end
end

