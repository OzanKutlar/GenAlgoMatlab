% Runs the SP-BBBC Algorithm
%
% INPUT: none
%
% OUTPUT: 
% 'archive' is the best individuals with the attributes of [x1, x2, fitness_1, fitness_2, fitnessInv, strength, raw_fitness, density, fitness, index]
 
function [archive] = runBBBC()
    global bbbcs;       % big bang-big crunch settings
    bbbcs.N = 300;  % number of individuals
    bbbcs.k = 3; % number of individual to generate for every cmass
    bbbcs.n_variables = 3;
    bbbcs.numberOfObjectives = 2;
    bbbcs.isMin = [1 1];
    bbbcs.MAX_GENERATIONS = 100;
    bbbcs.bounds = [-5 5;-5 5; -5 5]; 
    bbbcs.cMass_n = 1;
    bbbcs.strengthIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 1;
    bbbcs.rawFitnessIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 2;
    bbbcs.densityIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 3;
    bbbcs.lastFitnessIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 4;
    bbbcs.solutionIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 5;
    bbbcs.crunchMethod = 'eq1';   % eq1, eq2
    rng shuffle

     %--RANDOM INITIALIZATION
    cMass = zeros(1,bbbcs.n_variables);        %   [x1, x2]
    pop = zeros(bbbcs.N,bbbcs.n_variables + bbbcs.numberOfObjectives + 5);    %   [x1, x2, fitness_1, fitness_2, strength, raw_fitness, density, fitness, index]
    pop = bigBangPhase();
    archive = zeros(bbbcs.N,bbbcs.n_variables + bbbcs.numberOfObjectives + 5);  
    %--EVALUATION
    pop = SPEA_Strength(pop);
    pop = SPEA_Raw_Fitness(pop);
    pop = SPEA_Density(pop);
    pop(:,bbbcs.lastFitnessIndex) = pop(:,bbbcs.rawFitnessIndex) + pop(:,bbbcs.densityIndex); % Fitness value
    
    %--SURVIVOR FOR NON_ELITES REMOVAL
    pop = sortrows(pop,bbbcs.lastFitnessIndex,"ascend");
    archive = pop(pop(:,bbbcs.lastFitnessIndex) < 1, :); % non-dominated solutions
    archive = Survival_SPEA2(archive, pop);
    for i=1:height(pop)
        archive(i,bbbcs.solutionIndex) = i; % update the indices
    end

    for t=1:1:bbbcs.MAX_GENERATIONS
        if t~=1
            archive = bigBangPhase_1(cMass,t,archive);
        end
        
        cMass = bigCrunchPhase(archive,bbbcs.crunchMethod);
        
        first_obj = archive(:,4); %fitness_1
        second_obj= archive(:,5); %fitness_2
        scatter(first_obj,second_obj,'filled','DisplayName',num2str(1))
        
        legend
        drawnow
        hold off
    end       
end



