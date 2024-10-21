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

gas.algotihm_name = "RP-NSDE";
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


