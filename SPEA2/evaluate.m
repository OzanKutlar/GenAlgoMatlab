% Evaluate the fitness of the individuals in the population 
%
% INPUT: 
% 'pop' is the population to be evaluated 
%
% OUTPUT: 
% 'fit_array', is a matrix with 'fitness values' and 'index in the pop array'
function [pop, fit_array] = evaluate(pop)
    global gas; % genetic algorithm settings
    
    fit_array = zeros(gas.n_individuals,gas.fitArraySize);

    for i=1:gas.n_individuals 
        fit_array(i,1) = pop(i,1); % first function x
        fit_array(i,2) = 1+ pop(i,2) - pop(i,1)^2; % second function 1 + y - x^2
        % ADD FUNCTIONS HERE
        fit_array(i,3) = pop(i,1);
        fit_array(i,gas.numberOfObjectives + 1) = i; % index for later use
    end
end  
