% Evaluate fitness for a population of individuals
%
% INPUT: 
% 'pop' is the population to be evaluated [t+1 x n+4 x n_individuals]
%
% OUTPUT: 
% 'fit_array', is a matrix with fitness values, composed of 'ik fitness', 'number of nodes', 'rank fitness', 'index in the pop array'[n_individuals x 4]
function [pop, fit_array] = evaluate(pop)
    global gas; % genetic algorithm settings
    global op;
    
    fit_array = zeros(gas.n_individuals,gas.n_ObjectiveFunctions+3);

    if startsWith(upper(op.name), "DTLZ")
        fit_array(:, 1:gas.n_ObjectiveFunctions) = benchmark(pop);
        for i = 1:gas.n_individuals
            fit_array(i,gas.n_ObjectiveFunctions+1) = i;
        end
    else
        for i=1:gas.n_individuals 
            %objfunc is function that includes all of your objective function
            %that function takes 1 chrom and return their fitness'
            fit_array(i,1:gas.n_ObjectiveFunctions)=objfunc(pop(i,:));
            fit_array(i,gas.n_ObjectiveFunctions+1) = i;
        end
    end
end


