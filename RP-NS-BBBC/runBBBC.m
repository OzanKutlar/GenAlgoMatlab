function runBBBC()
    
    global bbbcs;       % big bang-big crunch settings
    addpath '..\Shared'
    addpath '..\CompareMethods\'
    global op;          % Optimization problem
    op.name = "dtlz1";
    benchmark(zeros(2,2), true);
    global parameters
    parameters.division = 4;

    bbbcs.N = 900;
    bbbcs.n_cmass = 100;
    bbbcs.k = bbbcs.N / bbbcs.n_cmass; % number of individual to generate for every cmass
    bbbcs.maxFE = 50 * 10 * 1000;
    bbbcs.n_variables = op.numberOfDecisionVar;
    bbbcs.numberOfObjectives = op.numberOfObjectives;
    bbbcs.isMin = ones(1, op.numberOfObjectives);
    bbbcs.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);
    bbbcs.strongDominance=false;
    bbbcs.crunchMethod = 'eq2';   % eq1, eq2
    bbbcs.rankIndex = bbbcs.n_variables + bbbcs.numberOfObjectives + 1;
    bbbcs.crowdingDistIndex = bbbcs.rankIndex + 1;
    bbbcs.solutionIndex = bbbcs.crowdingDistIndex + 1;
    rng shuffle
    cMass = zeros(1,bbbcs.n_variables);        %   [x1, x2]
    pop = zeros(bbbcs.N,bbbcs.solutionIndex);    %   [x1, x2, fitness, fitness2, Rank, Crowding distance]
    pop = bigBangPhase();
    pop = nonDomSorting(pop);
    pop = crowding_distance_BBBC(pop);
    % speed = (2.^linspace(-7, 7, bbbcs.MAX_GENERATIONS));

    t = 0;
    igd_arr = [];
    while op.currentFE < bbbcs.maxFE
        t = t + 1;
        op.currentGen = t;
        if t~=1
            pop = bigBangPhase_1(cMass,t,pop);
        end
        
        tic
%         if pop(1,3) <= 1e-5
%             break
%         end
        cMass = bigCrunchPhase(pop,bbbcs.crunchMethod);
        
        first_obj = pop(:,bbbcs.n_variables + 1);
        second_obj= pop(:,bbbcs.n_variables + 2);
        third_obj= pop(:,bbbcs.n_variables + 3);

        igd_arr(1, end + 1) = igd(pop(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives), get_pf(op.name, bbbcs.N));
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
    pareto.data = pop(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives);
    pareto.N = bbbcs.N;
    
    counter = 1;
    while isfile("result" + counter + ".mat")
        counter = counter + 1;
    end
    save("result" + counter + ".mat", "pareto");
end



