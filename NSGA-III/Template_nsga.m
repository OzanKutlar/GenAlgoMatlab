function Template_nsga(problem, fe, individuals)

global gas;         % genetic algorithm settings
global op; 

switch nargin
    case 0
        op.name = "dtlz1";
        gas.maxFE = 20000;
        gas.n_individuals = 92;
    case 3
        op.name = problem;
        gas.maxFE = fe;
        gas.n_individuals = individuals;
end

addpath('..\Shared');
addpath('..\CompareMethods');
benchmark(zeros(2,2), true);

gas.p_divisions = 8;
gas.algotihm_name = "NSGA-III";
gas.n_variables = op.numberOfDecisionVar;
gas.isMin = ones(1, op.numberOfObjectives);
gas.eta_crossover = 20;
gas.eta_mutation = 50;
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


