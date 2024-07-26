function bbbc()
    global bbbcs;       % big bang-big crunch settings
    addpath '..\Shared'
    global op;          % Optimization problem
    op.name = "zdt3";
    benchmark(zeros(2,2), true);
    global parameters
    parameters.division = 8;
    
    bbbcs.N = 600;
    bbbcs.n_cmass = 45;
    bbbcs.k = bbbcs.N / bbbcs.n_cmass; % number of individual to generate for every cmass
    bbbcs.MAX_GENERATIONS = 100;
    bbbcs.n_variables = op.numberOfDecisionVar;
    bbbcs.numberOfObjectives = op.numberOfObjectives;
    bbbcs.isMin = ones(1, op.numberOfObjectives);
    bbbcs.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);
    bbbcs.strongDominance=false;
    bbbcs.crunchMethod = 'eq1';   % eq1, eq2
    rng shuffle
    
    pop(bbbcs.N) = struct('position', [], 'paretoPosition', []);
    pop = initUniverse(pop);
    speed = 10.^-(min(linspace(0, 4, bbbcs.MAX_GENERATIONS), 1.65));

    for i = 1:bbbcs.MAX_GENERATIONS
        tic
        nonDominated = getNonDominatedPop(pop);
        
        cMass = selectCentralMass(nonDominated);

        displayFigure(cMass, pop, speed, i);
        
        pop = explode(cMass, speed(i));

        pop = evaluate(pop);
        toc
    end
    
    pareto = getParetoSpace(cMass);
    if(width(pareto) == 2)
        scatter(pareto(:, 1), pareto(:, 2), 40, 'filled');
    else
        scatter3(pareto(:, 1), pareto(:, 2), pareto(:, 3), 40, 'filled');
    end
end

function displayFigure(elites, all, speedCurve, generation)
    pareto = getParetoSpace(all);
    pareto2 = getParetoSpace(elites);
    pareto = vertcat(pareto, pareto2);
    mu = repmat([0, 0, 0], height(pareto), 1);
    for ii = width(all) + 1:height(pareto)
        mu(ii, :) = [0, 1, 1];
    end
    
    % pareto = getParetoSpace(selectedElites);
    subplot(2, 1, 1)
    if(width(pareto) == 2)
        scatter(pareto(:, 1), pareto(:, 2), 40, mu, 'filled');
    else
        scatter3(pareto(:, 1), pareto(:, 2), pareto(:, 3), 40, mu, 'filled');
    end
    subplot(2, 1, 2)
    plot(speedCurve);
    xline(generation);
    drawnow
end

function pop = explode(cMass, range)
    global bbbcs
    pop(bbbcs.N + 1) = cMass(1);
    pop(bbbcs.N + 1) = [];
    pop(1:width(cMass)) = cMass;
    selected = width(cMass);
    for i = 1:width(cMass)
        currentCenter = cMass(i);

        for ii = 1:bbbcs.k
            selected = selected + 1;
            pop(selected) = currentCenter;
            pop(selected).position = pop(selected).position + (rand(1, width(pop(selected).position)) - 0.5) * range * 2;
            for iii = 1:bbbcs.n_variables
                pop(selected).position(iii) = max(min(pop(selected).position(iii), bbbcs.bounds(iii, 2)), bbbcs.bounds(iii, 1));
            end
            if(selected == bbbcs.N)
                break;
            end
        end
        if(selected == bbbcs.N)
            break;
        end
    end
end


function pop = getNonDominatedLayer(nonDominated, targetLayer)
    currentLayer = 1;
    startPoint = 0;
    endPoint = width(nonDominated);
    for i = 1:width(nonDominated)
        if(currentLayer == targetLayer && startPoint == 0)
            startPoint = i;
        end
        if(isempty(nonDominated(i).position))
            if(currentLayer == targetLayer)
                endPoint = i - 1;
                break;
            end
            currentLayer = currentLayer + 1;
        end
    end
    pop = nonDominated(startPoint:endPoint);
end

function pop = initUniverse(pop)
    global bbbcs
    for i = 1:width(pop)
        % Assign random values to the position, velocity, and personalBest
        for ii = 1:bbbcs.n_variables
            pop(i).position(ii) = bbbcs.bounds(ii, 1) + (bbbcs.bounds(ii, 2)-bbbcs.bounds(ii, 1)) .* rand(1, 1);
        end
    end
    pop = evaluate(pop);
end

function pop = evaluate(pop)
    global op
    if(startsWith(op.name, "DTLZ"))
        pop = evaluateWholeAtOnce(pop);
        return;
    end
    for i = 1:width(pop)
        pop(i).paretoPosition = benchmark(pop(i).position);
    end
end

function pop = evaluateWholeAtOnce(pop)
    position = zeros(width(pop), width(pop(1).position));
    for i = 1:width(pop)
        position(i, :) = pop(i).position;
    end
    result = benchmark(position);
    for i = 1:width(pop)
        pop(i).paretoPosition = result(i, :);
    end
end


function cMass = selectCentralMass(nonDom)
    global bbbcs
    selectedElites = 0;
    cMass(bbbcs.n_cmass + 1) = nonDom(1);
    cMass(bbbcs.n_cmass + 1) = [];

    layers(max(width(nonDom) - bbbcs.N, 1)) = struct('layer', []);
        
    layerPop = getNonDominatedLayer(nonDom, 1);

    [normalizedLayer, reference_directions] = doNormalize(getParetoSpace(layerPop));
    assosiations = assosiate(normalizedLayer, reference_directions, layerPop);
    
    layers(1).layer = assosiations;
    
    currentLayer = ones(1, width(assosiations));
    i = 1;
    while true
        if(selectedElites == bbbcs.n_cmass)
            break
        end
        if(i == width(assosiations) + 1)
            i = 1;
        end

        myLayer = layers(currentLayer(i)).layer;
        if(isempty(myLayer))
            layerPop = getNonDominatedLayer(nonDom, currentLayer(i));
            [normalizedLayer, reference_directions] = doNormalize(getParetoSpace(layerPop));
            assosiations = assosiate(normalizedLayer, reference_directions, layerPop);
            layers(currentLayer(i)).layer = assosiations;
            myLayer = layers(currentLayer(i)).layer;
        end
        if(myLayer(i).count <= 1)
            if(max(width(nonDom) - bbbcs.N, 1) == currentLayer(i))
                i = i + 1;
                continue;
            end
            currentLayer(i) = currentLayer(i) + 1;
            continue;
        end
        
        randomCandidate = round(rand() * (myLayer(i).count - 2)) + 1;

        selectedElites = selectedElites + 1;
        cMass(selectedElites) = myLayer(i).pop(randomCandidate).position;
        layers(currentLayer(i)).layer(i).pop(randomCandidate) = [];
        layers(currentLayer(i)).layer(i).count = layers(currentLayer(i)).layer(i).count - 1;

        i = i + 1;
    end
end

% Input : the population
% Output : non dominating layers, each layer has an empty particle in
% between them. Can be checked using isempty
function newPop = getNonDominatedPop(pop)
    layer = 0;
    pareto = getParetoSpace(pop);
    originalSize = width(pop);
    index = 1;
    while true
        newPop(originalSize + 1 + layer) = pop(1);
        newPop(originalSize + 1 + layer) = [];
        removed = 0;
        nextSwarm = pop;
        nextPareto = pareto;
        for i = 1:width(pop)
            particle = pop(i).paretoPosition;
            isDominated = checkDom(particle, pareto);
            

            if ~isDominated
                newPop(index) = pop(i);
                nextSwarm(i - removed) = [];
                nextPareto(i - removed, :) = [];
                index = index + 1;
                removed = removed + 1;
            end
        end
        if(width(nextSwarm) == 0)
            break;
        end
        pop = nextSwarm;
        pareto = nextPareto;
        layer = layer + 1;
        index = index + 1;
    end
end

% Input : single particle's pareto location, all pareto locations
% Output : Boolean, is the particle dominated by others?
function isDominated = checkDom(pos, pareto)
    isDominated = false;
    for i = 1:height(pareto)
        if(all(pareto(i, :) <= pos) && any(pareto(i, :) < pos))
        % if(all(pareto(i, :) < particle))
            isDominated = true;
            break;
        end
    end
end

% Input : Population Array
% Output : All pareto locations in an array
function pareto = getParetoSpace(pop)
    pareto = ones(width(pop), width(pop(1).paretoPosition)) * Inf;
    for i = 1:width(pop)
        if(isempty(pop(i).paretoPosition))
            continue;
        end
        pareto(i, :) = pop(i).paretoPosition;
    end
end