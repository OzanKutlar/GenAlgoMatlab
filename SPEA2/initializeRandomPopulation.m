% Initialize the Random Population
%
% INPUT: none
%
% OUTPUT: 
% 'pop' is the population at the first generation of the algorithm 

function [pop] = initializeRandomPopulation()
    global gas; % genetic algorithm settings

    % declare a static array of chromosomes filled with zeros
    pop = zeros(gas.n_individuals,2);
    
    % create a random chromosome for each individual in the population
    for i=1:1:gas.n_individuals
        chrom = generateRandomChromosome();   
        pop(i,:) = chrom;
    end
    
end
