function [pop] = initializeRandomPopulation()
    
    global op;  % optimization problem
    global gas; % genetic algorithm settings

    % declare a static array of chromosomes filled with zeros
    pop = zeros(gas.n_individuals,gas.n_variables);
    
    for i=1:1:gas.n_individuals
        chrom = generateRandomChromosome();   
        pop(i,:) = chrom;
    end
    
end