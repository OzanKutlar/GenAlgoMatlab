function regularPSO(problem, data)
    clear global
    global op parameters;
    if nargin < 1 || isempty(problem)
        problem = 'kur'; % Default problem
    end
    
    if nargin < 2 || isempty(data)
        data.pop = 500;
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
    parameters.personalConst = 1;
    parameters.socialConst = 2;
    parameters.maxFE = 50000;
    parameters.inertia = 1;
    
    swarm = generatePopulation();
    swarm = determineTarget(swarm);

    minArr = min(op.bounds(:, 1), op.bounds(:, 2));
    maxArr = max(op.bounds(:, 1), op.bounds(:, 2));
    minArr = repmat(minArr', parameters.pop, 1);
    minArr = repmat(maxArr', parameters.pop, 1);

    displayFigure(swarm.pareto, swarm.target);

    % while(op.currentFE < parameters.maxFE)
    % 
    % 
    % end

    function swarm = updateVelocity(swarm)
        swarm.velocity = (parameters.inertia * swarm.velocity);
        swarm.velocity = swarm.velocity + (parameters.personalConst * rand(size(swarm.velocity)) * (swarm.best - swarm.pos));
        swarm.velocity = swarm.velocity + (parameters.socialConst * rand(size(swarm.velocity)) * (swarm.target - swarm.pos));
        swarm.pos = swarm.velocity + swarm.pos;
    end



    function swarm = determineTarget(swarm)
        pareto = getParetoFront(swarm);
        swarm.target = pareto(randi(height(pareto), height(swarm.pos), 1), :);
    end


    function paretoFront = getParetoFront(swarm)
        
        isDominated = false(1, height(swarm.pareto));
        
        for i = 1:height(swarm.pareto)
            pos_i = swarm.pareto(i, :);

            temp2 = swarm.pareto <= pos_i; 
            
            temp1 = swarm.pareto < pos_i;
            
            isDominated(i) = any(all(temp2, 2) & any(temp1, 2) & (1:height(swarm.pareto) ~= i)');
        end
        
        paretoFront = swarm.pareto(~isDominated, :);

    end
    
    function swarm = generatePopulation()
        diffArr = maxArr - minArr;
        randArr = rand(parameters.pop, op.numberOfDecisionVar);

        
        diffArr = repmat(diffArr', parameters.pop, 1);
        swarm.pos = (randArr .* diffArr) + minArr;

        randArr = rand(parameters.pop, op.numberOfDecisionVar);
        swarm.velocity = randArr .* diffArr + minArr;
        swarm.best = swarm.pos;
        swarm.pareto = benchmark(swarm.pos);
        swarm.bestPareto = swarm.pareto;
    end


end


