clear all
global parameters;
global op;
op.name = "zdt1";
addpath('..\Shared');
% whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 1000; % Number of particles
parameters.personalConst = 1;
parameters.socialConst = 2;
parameters.maxFE = 50000; % Maximum number of function evaluations to be used.
parameters.socialDistance = 1; % Distance at which particles are moved apart.
parameters.eliteCount = parameters.particleCount * 0.5; % 10% of the population as elites by default

% Create a structure array to hold the particles
swarm(parameters.particleCount) = struct('position', [], 'velocity', [], 'personalBest', [], 'paretoPosition', []);

% Use a loop to initialize the particles
for i = 1:parameters.particleCount
    % Assign random values to the position, velocity, and personalBest
    swarm(i).velocity = rand(1, op.numberOfDecisionVar);
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

igd_arr = [];
while op.currentFE < parameters.maxFE
    
    nonDomLayers = getNonDominatedSwarm(swarm);
    
    % Select elites from the non-dominated solutions
    
    selectedElites = selectElites(nonDomLayers, selectedElites);

    % Update and evaluate
    swarm = updatePositions(swarm, selectedElites);
    
    swarm = evaluate(swarm);

    igd_arr(1, end + 1) = igd(getParetoSpace(selectedElites), get_pf(op.name, parameters.particleCount));
    fprintf('Function Eval : %d/%d \n',op.currentFE, parameters.maxFE);

    displayFigure(selectedElites, swarm, igd_arr)

end

disp("Finished!")
fprintf('Convergence Score: %d \n', sum(igd_arr));

return;
pareto = getParetoSpace(selectedElites);
scatter(pareto(:, 1), pareto(:, 2), 'filled');
clear pareto

paretoFront = getParetoSpace(selectedElites);

pareto.name = op.name;
pareto.data = paretoFront;
pareto.N = parameters.eliteCount;

counter = 1;
while isfile("result" + counter + ".mat")
    counter = counter + 1;
end
save("result" + counter + ".mat", "pareto");

function displayFigure(elites, all, igd_arr)
    pareto = getParetoSpace(all);
    pareto2 = getParetoSpace(elites);
    pareto = vertcat(pareto, pareto2);
    mu = repmat([0, 0, 0], height(pareto), 1);
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
    plot(igd_arr);
    xlabel('Generations');
    ylabel('IGD');
    xline(width(igd_arr), '-r', strcat('Current IGD : ', num2str(igd_arr(end))));
    axis padded

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
                break;
            end
        end

        if(isElite)
            continue;
        end

        globalBest = round(rand() * (width(elites) - 1)) + 1;
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

