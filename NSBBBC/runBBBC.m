function [pop] = runBBBC()
    
    global bbbcs;       % big bang-big crunch settings
    addpath '..\Shared'
    global op;          % Optimization problem
    op.name = "ZDT1";
    benchmark(zeros(2,2), true);

    bbbcs.N = 100;
    bbbcs.n_cmass = bbbcs.N / 10;
    bbbcs.k = bbbcs.N / bbbcs.n_cmass; % number of individual to generate for every cmass
    bbbcs.MAX_GENERATIONS = 100;
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
    for t=1:1:bbbcs.MAX_GENERATIONS
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
        toc
        clf
        if op.numberOfObjectives == 2
            scatter(first_obj,second_obj,'filled','DisplayName',strcat("NSBBBC Generating gen : ", num2str(t)))
        end
        if op.numberOfObjectives == 3
            scatter3(first_obj, second_obj, third_obj,'filled','DisplayName', strcat("NSBBBC Generating gen : ", num2str(t)) )
        end
        legend
        drawnow
    end
           
end



