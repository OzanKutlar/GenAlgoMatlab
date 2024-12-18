function regularPSO(problem, data)
    clear global
    global op parameters;
    if nargin < 1 || isempty(problem)
        problem = 'zdt1'; % Default problem
    end
    
    if nargin < 2 || isempty(data)
        data.pop = 10000;
        data.fe = 500;
    else
        if ~isfield(data, 'pop')
            data.pop = 500;
        end
        if ~isfield(data, 'fe')
            data.fe = 500;
        end
    end
    addpath('..\Shared');
    setup(problem);
    parameters.pop = 500;
    parameters.personalConst = 0.01;
    parameters.socialConst = 0.02;
    parameters.maxFE = Inf;
    parameters.inertia = 1;

    minArr = min(op.bounds(:, 1), op.bounds(:, 2));
    maxArr = max(op.bounds(:, 1), op.bounds(:, 2));
    minArr = repmat(minArr', parameters.pop, 1);
    maxArr = repmat(maxArr', parameters.pop, 1);
    
    swarm = generatePopulation();
    swarm = determineTarget(swarm);


    while(op.currentFE < parameters.maxFE)
        if nargin < 1
            whitebg("black");
            displayFigure(swarm.pareto, swarm.targetPareto);
        end
        swarm = updatePhysics(swarm);

        swarm = updateSwarmData(swarm);
        swarm = determineTarget(swarm);

        
    end

    function swarm = updateSwarmData(swarm)
        swarm.pareto = benchmark(swarm.pos);
        temp2 = swarm.pareto <= swarm.bestPareto; % Make sure that all decision vars are at least as good as the best.
        temp1 = swarm.pareto < swarm.bestPareto; % Make sure that any of the decision vars are better.
        isBetter = any(temp1, 2) & all(temp2, 2);
        swarm.bestPareto(isBetter) = swarm.pareto(isBetter);
        swarm.best(isBetter) = swarm.pos(isBetter);
    end

    function swarm = updatePhysics(swarm)
        swarm.velocity = (parameters.inertia * swarm.velocity);
        swarm.velocity = swarm.velocity + ((parameters.personalConst * rand(size(swarm.velocity))) .* (swarm.best - swarm.pos));
        swarm.velocity = swarm.velocity + ((parameters.socialConst * rand(size(swarm.velocity))) .* (swarm.target - swarm.pos));
        swarm.pos = swarm.velocity + swarm.pos;
        minIndex = swarm.pos < minArr;
        maxIndex = swarm.pos > maxArr;
        swarm.pos(minIndex) = minArr(minIndex);
        swarm.pos(maxIndex) = maxArr(maxIndex);
    end



    function swarm = determineTarget(swarm)
        [pareto, paretoDecision] = getParetoFront(swarm);
        randomIndexes = randi(height(paretoDecision), height(swarm.pos), 1);
        swarm.target = paretoDecision(randomIndexes, :);
        swarm.targetPareto = pareto(randomIndexes, :);
    end


    function [paretoFront, decisionPareto] = getParetoFront(swarm)
        
        isDominated = false(1, height(swarm.pareto));
        
        for i = 1:height(swarm.pareto)
            pos_i = swarm.pareto(i, :);

            temp2 = swarm.pareto <= pos_i; 
            
            temp1 = swarm.pareto < pos_i;
            
            isDominated(i) = any(all(temp2, 2) & any(temp1, 2) & (1:height(swarm.pareto) ~= i)');
        end
        
        paretoFront = swarm.pareto(~isDominated, :);
        decisionPareto = swarm.pos(~isDominated, :);

    end
    
    function swarm = generatePopulation()
        diffArr = maxArr - minArr;
        randArr = rand(parameters.pop, op.numberOfDecisionVar);

        swarm.pos = (randArr .* diffArr) + minArr;

        randArr = rand(parameters.pop, op.numberOfDecisionVar);
        swarm.velocity = randArr .* diffArr + minArr;
        swarm.best = swarm.pos;
        swarm.pareto = benchmark(swarm.pos);
        swarm.bestPareto = swarm.pareto;
    end


end


