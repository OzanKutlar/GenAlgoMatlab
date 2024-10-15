clear;
clc;
clf;
global parameters;
global op;
op.name = "zdt1";
addpath('..\Shared');
addpath('..\CompareMethods');
% whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 100; % Number of particles
parameters.personalConst = 1;
parameters.socialConst = 2;
parameters.maxFE = 50000; % Maximum number of function evaluations to be used.
parameters.division = 4; % Amount of divisions per dimension for the reference directions
parameters.speedLimit = abs(op.bounds(1, 2) - op.bounds(1, 1));

parameters.elasticity = 0; % Bounce back speed


parameters.eliteCount = parameters.particleCount * 0.5;
% parameters.eliteCount = 15;

% Create a structure array to hold the particles
swarm(parameters.particleCount) = struct('position', [], 'velocity', [], 'personalBest', [], 'paretoPosition', [], 'globalStrength', []);

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
% speed = 10.^-(min(linspace(0, 6, parameters.iterationTime), 1));
% speed2 = 10.^-(min(linspace(0, 4, parameters.iterationTime), 2));
% speed = speed(1:parameters.iterationTime);
% speed2 = speed2(1:parameters.iterationTime);

igd_arr = [];
while op.currentFE < parameters.maxFE
    % parameters.personalConst = 0.1 * speed2(i);
    % parameters.socialConst = 0.2 * speed2(i);
    % parameters.speedLimit = speed(i);
    
    
    % thisGenElites = getParetoSwarm(swarm);
    
    selectedElites = selectElites(swarm, selectedElites);

    % Update and evaluate
    swarm = updatePositions(swarm, selectedElites);
    
    swarm = evaluate(swarm);

    igd_arr(1, end + 1) = igd(getParetoSpace(selectedElites), get_pf(op.name, parameters.particleCount));
    fprintf('Function Eval : %d/%d \n',op.currentFE, parameters.maxFE);
    
    displayFigure(selectedElites, swarm, igd_arr);
end

disp("Finished!")

return;

% pareto.name = op.name;
% pareto.data = paretoFront;
% pareto.N = parameters.particleCount;
% 
% counter = 1;
% while isfile("result" + counter + ".mat")
%     counter = counter + 1;
% end
% save("result" + counter + ".mat", "pareto");


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


function elites = selectElites(swarm, elites)
    global parameters;
    
    newElites = horzcat(swarm, elites);
    if(isempty(elites(1).position))
        newElites = swarm;
    end
    % elites = getParetoSwarm(newElites);
    eliteCount = 0;

    newElites = calculateGlobalStrength(newElites);

    [normalizedSwarm, reference_directions] = doNormalize(getParetoSpace(newElites));
    assosiations = assosiate(normalizedSwarm, reference_directions, newElites);

    longestAngle = 0;
    for i = 1:width(assosiations)
        ang1 = reference_directions(i, :);
        for j = i:width(assosiations)
            ang2 = reference_directions(j, :);
            angleBet = calculateAngleBetweenTwoLines(ang1, ang2);
            if(angleBet > longestAngle)
                longestAngle = angleBet;
            end
        end
    end

    clear ang1 ang2 angleBet i j 


    for i = 1:width(assosiations)
        assosiations(i) = calculateFitnesses(assosiations(i), reference_directions(i, :), longestAngle);
    end

    fitnessAll(width(assosiations) + 1) = struct('array', []);
    fitnessAll(width(assosiations) + 1) = [];

    empty = zeros(size(assosiations));
    for i = 1:width(assosiations)
        if(isempty(assosiations(i).swarm))
            empty(i) = 1;
            continue;
        end
        fitnessIndex = vertcat(assosiations(i).swarm(1:assosiations(i).count - 1).fitness);
        number = (1:height(fitnessIndex))';
        fitnessIndex = horzcat(fitnessIndex, number);
        fitnessIndex = sortrows(fitnessIndex, 1);
        fitnessAll(i).array = horzcat(fitnessIndex);
    end


    toBeAdded = ones(size(assosiations)) * floor((parameters.eliteCount - eliteCount) / width(assosiations) - sum(empty));
    while(eliteCount < parameters.eliteCount)
        % toBeAdded(empty == 0) = ones(1, width(assosiations) - sum(empty)) * floor(sum(toBeAdded) / (width(assosiations) - sum(empty)));
        if(parameters.eliteCount - eliteCount < (width(assosiations) - sum(empty)))
            temp((width(assosiations) - sum(empty)) + 1) = struct('pos', [], 'fit', []);
            temp((width(assosiations) - sum(empty)) + 1) = [];
            added = 0;
            for i = 1:width(assosiations)
                if(empty(i) == 1 || assosiations(i).count <= 1)
                    continue;
                end
                swarm = horzcat(assosiations(i).swarm(:).position);
                added = added + 1;
                temp(added).pos = swarm(fitnessAll(i).array(1, 2));
                temp(added).fit = fitnessAll(i).array(1, 1);
            end
            removed = (width(assosiations) - sum(empty)) - (parameters.eliteCount - eliteCount);
            while(removed ~= 0)
                fattest = 0;
                fattestIn = 0;
                for i = 1:added
                    if(temp(i).fit >= fattest)
                        if(temp(i).fit == fattest && rand() > 0.5)
                            continue;
                        end
                        fattest = temp(i).fit;
                        fattestIn = i;
                    end
                end
                temp(fattestIn) = [];
                added = added - 1;
                removed = removed - 1;
            end
            elites(eliteCount + 1:parameters.eliteCount) = horzcat(temp(:).pos);
            break;
        end
        toBeAdded(empty == 0) = ones(1, width(assosiations) - sum(empty)) * floor((parameters.eliteCount - eliteCount) / (width(assosiations) - sum(empty)));
        toBeAdded(empty == 1) = 0;
        for i = 1:width(assosiations)
            if(empty(i) == 1 || assosiations(i).count <= 1)
                empty(i) = 1;
                continue;
            end
            addedFromHere = min(toBeAdded(i), assosiations(i).count - 1);
            if(addedFromHere == assosiations(i).count - 1)
                empty(i) = 1;
            end
            swarm = horzcat(assosiations(i).swarm(:).position);
            elites(eliteCount + 1:eliteCount + addedFromHere) = swarm(fitnessAll(i).array(1:addedFromHere, 2));
            fitnessAll(i).array(1:addedFromHere, :) = [];
            assosiations(i).count = assosiations(i).count - addedFromHere;
            eliteCount = eliteCount + addedFromHere;
            toBeAdded(i) = toBeAdded(i) - addedFromHere;
        end
    end
   
end

function ref_direction = calculateFitnesses(ref_direction, ref_point, maxRef_pointAngle)
    swarm = ref_direction.swarm;

    strength = zeros(size(swarm(1:ref_direction.count - 1)));
    for i = 1:ref_direction.count - 1
        [swarm(i).fitness, strength] = dominatesHowMany(swarm(i).position, horzcat(swarm(1:ref_direction.count - 1).position), strength);
    end

    for i = 1:ref_direction.count - 1
        angleOfPart = calculateAngleBetweenTwoLines(swarm(i).position.paretoPosition, ref_point);
        strength(i) = strength(i) + (angleOfPart / (angleOfPart / maxRef_pointAngle));
    end

    for i = 1:ref_direction.count - 1
        ref_direction.swarm(i).fitness = strength(i) + ref_direction.swarm(i).position.globalStrength;
    end

end

function angle = calculateAngleBetweenTwoLines(line1, line2)
    v1_norm = line1 / norm(line1);
    v2_norm = line2 / norm(line2);
    
    dot_product = dot(v1_norm, v2_norm);
    
    dot_product = max(min(dot_product, 1.0), -1.0);
    
    angle = acos(dot_product);
end

function swarm = calculateGlobalStrength(swarm)
    strMat = zeros(size(swarm));
    for i = 1:width(swarm)
        [num, strMat] = dominatesHowMany(swarm(i), swarm, strMat);
    end
    for i = 1:width(swarm)
        swarm(i).globalStrength = strMat(i);
    end
end

% Input : particle to check, all the particles to check against, and a
% strenght matrix for preprocessing
% Output : number of points the particle dominates, and the strenght
% matrix updated accordingly
function [num, strengthMat] = dominatesHowMany(particle, pareto, strengthMat)
    num = 0;
    dominates = zeros(1, width(pareto));
    for i = 1:width(pareto)
        if(all(particle.paretoPosition <= pareto(i).paretoPosition) && any(particle.paretoPosition < pareto(i).paretoPosition))
            num = num + 1;
            dominates(i) = 1;
        end
    end
    strengthMat(dominates == 1) = strengthMat(dominates == 1) + num;
end

% Input : Particle Swarm, Elites
% Output : Particle Swarm
% Exp : Updates the swarm's velocity according to the newly selected elites
function swarm = updatePositions(swarm, elites)
    global parameters op;
    swarm(1:width(elites)) = elites;
    for i = 1:width(swarm)
        % if(isempty(swarm(i).target))
        %     globalBest = round(rand() * (width(elites) - 1)) + 1;
        %     swarm(i).target = elites(globalBest);
        % end
        % if(abs(sum(swarm(i).position - swarm(i).target.position)) <= 0.01)
        %     swarm(i).target = [];
        %     globalBest = round(rand() * (width(elites) - 1)) + 1;
        %     swarm(i).target = elites(globalBest);
        % end

        globalBest = round(rand() * (width(elites) - 1)) + 1;
        bestP = elites(globalBest);
        
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

