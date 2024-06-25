global pss;         % Particle Swarm settings
global op; 

op.name = "DTLZ1";  
addpath('..\Shared');
benchmark(zeros(2,2), true);

pss.p_divisions = 4;


parameters.particleCount = 10; % Number of particles
parameters.personalConst = 0.01; % Should the particle move towards its personal best?
parameters.socialConst = 0.01; % Should the particle move towards the pareto front?
parameters.iterationTime = 2000; % Maximum number of 'iterations' to run the simulation
parameters.elasticity = 0.6; % How much of the original speed should the particle bounce off the wall with?
parameters.socialDistance = 0.01; % Distance at which particles are moved apart.

pss.isMin = [1 1 1];
pss.n_ObjectiveFunctions=op.numberOfObjectives; % number of functions to solve
pss.strongDominance=false;
pss.selection_method = 'tournament';    % 'tournament', 'proportionate' 
pss.crossover_method = 'blxa';  % 'blxa'
pss.crossover_probability = 1;
pss.mutation_method = 'random';   % 'random', 'modifiedRandom', 'polynomial'
pss.mutation_probability = 0.2;  % 0.2, 0.4 ,0.6
pss.survival_method = 'elitist_full'; % 'elitist_full', 'elitist_alpha'




tic
    [pop, fit_array] = RunNSGA();
toc;


