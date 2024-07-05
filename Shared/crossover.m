% Perform crossover operator on a pair of parents
%
% INPUT:
% 'p1' is the chromosome of the first parent [t+1 x n+4]
% 'p2' is the chromosome of the second parent [t+1 x n+4]
%
% OUTPUT:
% 'o1' is the chromosome of the first child [t+1 x n+4]
% 'o2' is the chromosome of the second child [t+1 x n+4]
function [o1, o2] = crossover(p1, p2)

global op;  % optimization problem
global gas; % genetic algorithm settings

if rand() <= gas.crossover_probability
    % do crossover
    switch gas.crossover_method
        case 'blxa'
            alpha = 0.5;

            o1 = blendCrossover(p1, p2, alpha);
            o2 = blendCrossover(p1, p2, alpha);


        case 'sbx'
            eta = 2;
            o1 = sbxCrossover(p1, p2, eta, repmat(op.bounds(1), 1, op.numberOfDecisionVar), repmat(op.bounds(2), 1, op.numberOfDecisionVar));
            o2 = sbxCrossover(p1, p2, eta, repmat(op.bounds(1), 1, op.numberOfDecisionVar), repmat(op.bounds(2), 1, op.numberOfDecisionVar));
        otherwise
            error('Unexpected Crossover Method.');
    end
else
    % don't do crossover, copy from parents
    o1 = p1;
    o2 = p2;

end

end

%--------------BLX-ALPHA CROSSOVER--------------

function [child] = blendCrossover(p1, p2, alpha)
    global op;  % optimization problem
    global gas; % genetic algorithm settings
    child = zeros(1,op.numberOfDecisionVar);
    
    for i = 1:op.numberOfDecisionVar
        gamma = (1+2*alpha)*rand - alpha;
        if(p1(1,i) < p2(1,i))
            child(1,i) = (1-gamma)*p1(1,i) + gamma*p2(1,i);
        else
            child(1,i) = (1-gamma)*p2(1,i) + gamma*p1(1,i);
        end
    end
    for i = 1:op.numberOfDecisionVar
        child(1,i) = min(max(child(1,i),op.bounds(1)),op.bounds(2));
    end
end




%--------------SBX CROSSOVER--------------

function [child1, child2] = sbxCrossover(parent1, parent2, eta_c, lower_bound, upper_bound)
global op;  % optimization problem
global gas; % genetic algorithm settings
    % Simulated Binary Crossover (SBX)
    % Inputs:
    %   parent1, parent2 - Parent solutions
    %   eta_c - Distribution index for crossover
    %   lower_bound - Lower bound of the variables
    %   upper_bound - Upper bound of the variables
    % Outputs:
    %   child1, child2 - Child solutions
    
    % Ensure parents are row vectors
    if iscolumn(parent1)
        parent1 = parent1';
    end
    if iscolumn(parent2)
        parent2 = parent2';
    end
    
    % Initialize children
    child1 = zeros(size(parent1));
    child2 = zeros(size(parent2));
    
    % Number of decision variables
    nVar = length(parent1);
    
    for i = 1:nVar
        u = rand();
        if u <= 0.5
            beta = (2 * u)^(1 / (eta_c + 1));
        else
            beta = (1 / (2 * (1 - u)))^(1 / (eta_c + 1));
        end
        
        child1(i) = 0.5 * ((1 + beta) * parent1(i) + (1 - beta) * parent2(i));
        child2(i) = 0.5 * ((1 - beta) * parent1(i) + (1 + beta) * parent2(i));
        
        % Ensure children are within bounds
        child1(i) = min(max(child1(i), lower_bound(i)), upper_bound(i));
        child2(i) = min(max(child2(i), lower_bound(i)), upper_bound(i));
    end
end
