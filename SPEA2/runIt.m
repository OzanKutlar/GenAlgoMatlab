function runIt()
    
    %---------------------PROBLEM DEFINITION---------------------  
    addpath '..\Shared'
    global op;          % Optimization problem
    op.name = "zdt1";
    benchmark(zeros(2,2), true);
    %---------------------GA SETTINGS---------------------
    global gas;         % genetic algorithm settings
    
    %  IF THERE IS DIFFERENT BOUNDS FOR DECISION VARIABLES, op.bounds
    %  should be changed in benchmark.m, and also
    %  generateRandomChromosome.m should change
    
    % Evaluation functions can be added to the benchmark.m, number of
    % decision variables, bounds, and number of objectives should be
    % defined in benchmark.m too.
    

    gas.algotihm_name = "SPEA2";
    gas.maxFE = 50000;
    gas.isMin = [1 1 1]; %vector for determining if the objectives are to minimize or maximize, 1 for minimize, 0 for maximize
    gas.onlyStrictlyDominance = false;
    gas.n_individuals = 1000;
    gas.n_archive = gas.n_individuals;
    gas.selection_method = 'tournament';    % 'tournament', 'proportionate'
    gas.crossover_method = 'blxa';  % 'blxa'
    gas.crossover_probability = 1;
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

    pareto.name = op.name;
    pareto.data = fit_array(:, 1:op.numberOfObjectives);
    pareto.N = gas.n_individuals;
    
    counter = 1;
    while isfile("result" + counter + ".mat")
        counter = counter + 1;
    end
    save("result" + counter + ".mat", "pareto");
end
