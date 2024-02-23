function [offspring] = variation_generic(pop, matPool)
%UNTITLED6 Summary of this function goes here
global op;  % optimization problem
global gas; % genetic algorithm settings

% declare a static array of chromosomes filled with zeros
offspring = zeros(gas.n_individuals,gas.n_variables);

matPool = matPool(randperm(length(matPool))); % shuffle the mating pool

for i=1:gas.n_individuals

    % crossover
    index_p1 = matPool(i);
    index_p2 = matPool(i+1);

    p1 = pop(index_p1,:);
    p2 = pop(index_p2,:);

    [o1, o2] = crossover(p1, p2);
    % mutation
    o1 = mutation(o1);
    o2 = mutation(o2);

    offspring(i,:) = o1;
    offspring(i+1,:) = o2;
end

end