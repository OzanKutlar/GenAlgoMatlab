% Runs the SP-BBBC Algorithm
%
% INPUT: none
%
% OUTPUT: 
% 'archive' is the best individuals with the attributes of [x1, x2, fitness_1, fitness_2, fitnessInv, strength, raw_fitness, density, fitness, index]
 
function runBBBC()
    addpath '..\Shared'
    addpath '..\CompareMethods\'
    global bbbcs;       % big bang-big crunch settings

    global op;          % Optimization problem
    op.name = "dtlz1";
    benchmark(zeros(2,2), true);

    bbbcs.N = 900;  % number of individuals
    bbbcs.k = 45; % number of individual to generate for every cmass
    bbbcs.n_variables = op.numberOfDecisionVar;
    bbbcs.numberOfObjectives = op.numberOfObjectives;
    bbbcs.isMin = ones(1, op.numberOfObjectives);
    bbbcs.maxFE = 500000;
    bbbcs.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

%     bbbcs.cMass_n = 1;
    bbbcs.strengthIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 1;
    bbbcs.rawFitnessIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 2;
    bbbcs.densityIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 3;
    bbbcs.lastFitnessIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 4;
    bbbcs.solutionIndex = bbbcs.numberOfObjectives + bbbcs.n_variables + 5;
    bbbcs.crunchMethod = 'eq2';   % eq1, eq2
    rng shuffle

     %--RANDOM INITIALIZATION
    cMass = zeros(1,bbbcs.n_variables);        %   [x1, x2]
    pop = zeros(bbbcs.N,bbbcs.n_variables + bbbcs.numberOfObjectives + 5);    %   [x1, x2, fitness_1, fitness_2, strength, raw_fitness, density, fitness, index]
    pop = bigBangPhase(pop);
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

    t = 0;
    igd_arr = [];
    while op.currentFE < bbbcs.maxFE
        t = t + 1;
        op.currentGen = t;
        tic
        if t~=1
            archive = bigBangPhase_1(cMass,t,archive);
        end
        
        cMass = bigCrunchPhase(archive,bbbcs.crunchMethod);
        
        first_obj = archive(:,bbbcs.n_variables + 1); %fitness_1
        second_obj= archive(:,bbbcs.n_variables + 2); %fitness_2
        third_obj= archive(:,bbbcs.n_variables + 3); %fitness 3
        igd_arr(1, end + 1) = igd(archive(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives), get_pf(op.name, bbbcs.N));
        fprintf('Current FE: %d/%d \n',op.currentFE, bbbcs.maxFE);
        
        clf
        subplot(2,1,1);
        if op.numberOfObjectives == 2
            scatter(first_obj,second_obj,'filled','DisplayName',strcat("Function evaluations: ", num2str(op.currentFE)));
        end
        if op.numberOfObjectives == 3
            scatter3(first_obj,second_obj, third_obj,'filled','DisplayName', strcat("Function evaluations: ", num2str(op.currentFE)));
        end
        legend

        subplot(2,1,2);
        plot(igd_arr);
        xlabel('Generations');
        ylabel('IGD');
        xline(width(igd_arr), '-r', strcat('Current IGD : ', num2str(igd_arr(end))));
        axis padded
        
        % Added for continious figure
        drawnow
        %hold off
    end

    pareto.name = op.name;
    pareto.data = archive(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives);
    pareto.N = bbbcs.N;
    
    counter = 1;
    while isfile("result" + counter + ".mat")
        counter = counter + 1;
    end
    save("result" + counter + ".mat", "pareto");
end



