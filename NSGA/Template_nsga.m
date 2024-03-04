global gas;         % genetic algorithm settings
global op;          % Optimization problem
op.name = "df1";
benchmark(zeros(2,2), true);

gas.algotihm_name = "NSGA";
gas.generations = 100;
gas.n_individuals = 300;
gas.n_variables = op.numberOfDecisionVar;
gas.isMin = [1 1 1];
gas.n_ObjectiveFunctions=op.numberOfObjectives; % number of functions to solve
gas.strongDominance=false;
gas.selection_method = 'tournament';    % 'tournament', 'proportionate' 
gas.crossover_method = 'blxa';  % 'blxa'
gas.crossover_probability = 1;
gas.mutation_method = 'random';   % 'random', 'modifiedRandom', 'polynomial'
gas.mutation_probability = 0.6;  % 0.2, 0.4 ,0.6
gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'




tic
[pop, fit_array] = RunNSGA();
toc;


