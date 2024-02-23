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
            eta = 5;
            o1 = sbxCrossover(p1, p2, eta);
            o2 = sbxCrossover(p1, p2, eta);
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

function [o1, o2] = sbxCrossover(p1, p2, eta)
global op;  % optimization problem
global gas; % genetic algorithm settings
error('This Crossover Method is not implemented yet.');
end
