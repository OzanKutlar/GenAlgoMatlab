global gas;         % genetic algorithm settings
global op; 

op.name = "DTLZ2";  
addpath('..\Shared');
benchmark(zeros(2,2), true);


gas.p_divisions = 4;
gas.algotihm_name = "NSGA-III";
gas.generations = 100;
gas.n_individuals = 1200;
gas.n_variables = op.numberOfDecisionVar;
gas.isMin = [1 1 1];
gas.eta_crossover = 30;
gas.eta_mutation = 20;
gas.n_ObjectiveFunctions=op.numberOfObjectives; % number of functions to solve
gas.strongDominance=false;
gas.selection_method = 'tournament';    % 'tournament', 'proportionate' 
gas.crossover_method = 'sbx';
gas.crossover_probability = 1;
gas.mutation_method = 'polynomial';   % 'random', 'modifiedRandom', 'polynomial'
gas.mutation_probability = 1 / op.numberOfDecisionVar;  % 0.2, 0.4 ,0.6, 1
gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'




tic
    [pop, fit_array] = RunNSGA();
toc;


