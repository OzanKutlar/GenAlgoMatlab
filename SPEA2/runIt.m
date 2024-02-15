function [best_chrom, configurations] = runIt()
    
    %---------------------PROBLEM DEFINITION---------------------  
  
   
    %---------------------GA SETTINGS---------------------
    global gas;         % genetic algorithm settings
    
    % WHEN ADDING A NEW OBJECTIVE FUNCTION:
    % -Add to evaluate
    % -add to gas.isMin
    % -change the gas.numberOfObjectives
    gas.algorithm = "kur";

    % NOTE : Gene Bounds can be changed in generateRandomChromosome
    gas.numberOfDecisionVar = 3;
    gas.generations = 100;
    gas.numberOfObjectives = 3;
    gas.isMin = [1 1 1]; %vector for determining if the objectives are to minimize or maximize, 1 for minimize, 0 for maximize
    gas.onlyStrictlyDominance = false;
    gas.n_individuals = 300;
    gas.n_archive = gas.n_individuals;
    gas.selection_method = 'tournament';    % 'tournament', 'proportionate'
    gas.crossover_method = 'blxa';  % 'blxa'
    gas.crossover_probability = 0.9;
    gas.mutation_method = 'random';   % 'random', 'modifiedRandom'
    gas.mutation_probability = 0.2;  % -1 is dynamic 
    gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'
    
    gas.solutionIndex = gas.numberOfObjectives + 1;
    gas.strengthIndex = gas.numberOfObjectives + 2;
    gas.rawFitnessIndex = gas.numberOfObjectives + 3;
    gas.densityIndex = gas.numberOfObjectives + 4;
    gas.lastFitnessIndex = gas.numberOfObjectives + 5;
    gas.fitArraySize = gas.numberOfObjectives + 5;
     
    % Added so 1 figure can be updated continiously instead of opening
    % figures one by one.
    clf
    hold on
    
    %---------------------RUN---------------------
    rng shuffle;
        tic
        [pop, fit_array] = runGeneticAlgorithm();
        toc
end
