global gas;         % genetic algorithm settings
global op; 

op.name = "DTLZ1";  
addpath('..\Shared');
benchmark(zeros(2,2), true);

gas.algotihm_name = "RP-NSDE";
gas.generations = 200;
gas.n_individuals = 100;
gas.n_variables = op.numberOfDecisionVar;
gas.isMin = [1 1 1];
gas.n_ObjectiveFunctions=op.numberOfObjectives; % number of functions to solve
gas.strongDominance=false;
gas.selection_method = 'tournament';    % 'tournament', 'proportionate' 
gas.crossover_probability = 1;
gas.mutation_probability = 1 / op.numberOfDecisionVar;  % 0.2, 0.4 ,0.6, 1
gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'




tic
    [pop, fit_array] = RunNSGA();
toc;


