global gas;         % genetic algorithm settings
global op; 

op.name = "zdt1";  
addpath('..\Shared');
addpath('..\CompareMethods');
benchmark(zeros(2,2), true);

gas.algotihm_name = "NSDE";
gas.generations = 100;
gas.n_individuals = 100;
gas.n_variables = op.numberOfDecisionVar;
gas.isMin = ones(1, op.numberOfObjectives);
gas.n_ObjectiveFunctions=op.numberOfObjectives; % number of functions to solve
gas.strongDominance=false;
gas.scaling_factor = 0.85;
gas.crossover_probability = 0.8;
gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'




tic
    [pop, fit_array] = RunNSGA();
toc;


