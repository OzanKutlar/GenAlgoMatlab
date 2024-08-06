function runBBBC()
    
    global bbbcs;       % big bang-big crunch settings
    addpath '..\Shared'
    addpath('..\CompareMethods');
    global op;          % Optimization problem
    op.name = "zdt3";
    benchmark(zeros(2,2), true);

    bbbcs.N = 100;
    bbbcs.n_cmass = bbbcs.N / 10;
    bbbcs.k = bbbcs.N / bbbcs.n_cmass; % number of individual to generate for every cmass
    bbbcs.maxFE = 10000;
    bbbcs.n_variables = op.numberOfDecisionVar;
    bbbcs.numberOfObjectives = op.numberOfObjectives;
    bbbcs.isMin = ones(1, op.numberOfObjectives);
    bbbcs.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);
    bbbcs.strongDominance=false;
    bbbcs.crunchMethod = 'eq1';   % eq1, eq2
    bbbcs.rankIndex = bbbcs.n_variables + bbbcs.numberOfObjectives + 1;
    bbbcs.crowdingDistIndex = bbbcs.rankIndex + 1;
    bbbcs.solutionIndex = bbbcs.crowdingDistIndex + 1;
    rng shuffle
    cMass = zeros(1,bbbcs.n_variables);        %   [x1, x2]
    pop = zeros(bbbcs.N,bbbcs.solutionIndex);    %   [x1, x2, fitness, fitness2, Rank, Crowding distance]
    pop = bigBangPhase();
    pop = nonDomSorting(pop);
    pop = crowding_distance_BBBC(pop);

    igd_arr = [];
    t = 0;

    while op.currentFE < bbbcs.maxFE
        t = t + 1;
        op.currentGen = t;
        if t~=1
            pop = bigBangPhase_1(cMass,t,pop);
        end
        
        cMass = bigCrunchPhase(pop,bbbcs.crunchMethod);

        igd_arr(1, end + 1) = igd(pop(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives), get_pf(op.name, bbbcs.N));
        fprintf('Current FE: %d/%d \n',op.currentFE, bbbcs.maxFE);
        first_obj = pop(:,bbbcs.n_variables + 1);
        second_obj= pop(:,bbbcs.n_variables + 2);
        third_obj= pop(:,bbbcs.n_variables + 3);
        clf
        subplot(2,1,1);
        if op.numberOfObjectives == 2
            scatter(first_obj,second_obj,'filled','DisplayName',strcat("NSBBBC, Function Eval : ", num2str(op.currentFE), "/", num2str(bbbcs.maxFE)));
        end
        if op.numberOfObjectives == 3
            scatter3(first_obj, second_obj, third_obj,'filled','DisplayName', strcat("NSBBBC, Function Eval : ", num2str(op.currentFE), "/", num2str(bbbcs.maxFE)));
        end
        legend


        subplot(2,1,2);
        plot(igd_arr);
        xlabel('Generations');
        ylabel('IGD');
        xline(width(igd_arr), '-r', strcat('Current IGD : ', num2str(igd_arr(end))));
        axis padded


        drawnow
    end

    disp("Finished!");
fprintf('Convergence Score: %d \n', sum(igd_arr));

    pareto.name = op.name;
    pareto.data = pop(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives);
    pareto.N = bbbcs.N;
    
    counter = 1;
    while isfile("result" + counter + ".mat")
        counter = counter + 1;
    end
    save("result" + counter + ".mat", "pareto");
end



