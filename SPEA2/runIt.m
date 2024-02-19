function [best_chrom, configurations] = runIt()
    
    %---------------------PROBLEM DEFINITION---------------------  
    global op;          % Optimization problem
    op.name = "zdt2";
    benchmark(zeros(2,2));
    %---------------------GA SETTINGS---------------------
    global gas;         % genetic algorithm settings

    
    % WHEN ADDING A NEW OBJECTIVE FUNCTION:
    % -Add to evaluate
    % -add to gas.isMin
    % -change the gas.numberOfObjectives

    % NOTE : Gene Bounds can be changed in generateRandomChromosome
    gas.generations = 100;
    gas.isMin = [1 1 1]; %vector for determining if the objectives are to minimize or maximize, 1 for minimize, 0 for maximize
    gas.onlyStrictlyDominance = false;
    gas.n_individuals = 300;
    gas.n_archive = 300;
    gas.selection_method = 'tournament';    % 'tournament', 'proportionate'
    gas.crossover_method = 'blxa';  % 'blxa'
    gas.crossover_probability = 0.9;
    gas.mutation_method = 'random';   % 'random', 'modifiedRandom', 'polynomial'
    gas.mutation_probability = 0.2;  % -1 is dynamic 
    gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'
    
    gas.solutionIndex = op.numberOfObjectives + 1;
    gas.strengthIndex = op.numberOfObjectives + 2;
    gas.rawFitnessIndex = op.numberOfObjectives + 3;
    gas.densityIndex = op.numberOfObjectives + 4;
    gas.lastFitnessIndex = op.numberOfObjectives + 5;
    gas.fitArraySize = op.numberOfObjectives + 5;
     
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
