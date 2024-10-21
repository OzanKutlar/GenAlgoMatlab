function Template_nsga(problem, fe, individuals)

global gas;         % genetic algorithm settings
global op; 

switch nargin
    case 0
        op.name = "zdt1";
        gas.maxFE = 20000;
        gas.n_individuals = 100;
    case 3
        op.name = problem;
        gas.maxFE = fe;
        gas.n_individuals = individuals;
end

addpath('..\Shared');
benchmark(zeros(2,2), true);

gas.algotihm_name = "NSGA-II";
gas.n_variables = op.numberOfDecisionVar;
gas.isMin = ones(1, op.numberOfObjectives);
gas.n_ObjectiveFunctions=op.numberOfObjectives; % number of functions to solve
gas.strongDominance=false;
gas.selection_method = 'tournament';    % 'tournament', 'proportionate' 
gas.crossover_method = 'blxa';  % 'blxa'
gas.crossover_probability = 1;
gas.mutation_method = 'random';   % 'random', 'modifiedRandom', 'polynomial'
gas.mutation_probability = 0.2;  % 0.2, 0.4 ,0.6
gas.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'




tic
    [pop, fit_array] = RunNSGA();
toc;


