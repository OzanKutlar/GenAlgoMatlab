% Evaluate fitness for a population of individuals
%
% INPUT: 
% 'pop' is the population to be evaluated [t+1 x n+4 x n_individuals]
%
% OUTPUT: 
% 'fit_array', is a matrix with fitness values, composed of 'ik fitness', 'number of nodes', 'rank fitness', 'index in the pop array'[n_individuals x 4]
function [objectives] = evaluateIndividual(pop)
    global bbbcs;
    global op;
    
    objectives = zeros(bbbcs.N, bbbcs.numberOfObjectives);

    if startsWith(upper(op.name), "DTLZ")
        objectives(:, 1:bbbcs.numberOfObjectives) = benchmark(pop);
    else
        for i=1:bbbcs.N 
            %objfunc is function that includes all of your objective function
            %that function takes 1 chrom and return their fitness'
            objectives(i, 1:bbbcs.numberOfObjectives) = benchmark(pop(i,:));
        end
    end
end


