function [] = runBBBC()
    
    global bbbcs;       % big bang-big crunch settings

    bbbcs.N = 500;
    bbbcs.n_cmass = bbbcs.N / 10;
    bbbcs.k = bbbcs.N / bbbcs.n_cmass; % number of individual to generate for every cmass
    bbbcs.MAX_GENERATIONS = 100;
    bbbcs.n_variables = 2;
    bbbcs.numberOfObjectives = 2;
    bbbcs.bounds = [0 1; 0 3];
    bbbcs.isMin= [1 1];
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
    for t=1:1:bbbcs.MAX_GENERATIONS
        if t~=1
            pop = bigBangPhase_1(cMass,t,pop);
        end
        
        
%         if pop(1,3) <= 1e-5
%             break
%         end
        cMass = bigCrunchPhase(pop,bbbcs.crunchMethod);
        
        first_obj = pop(:,3);
        second_obj= pop(:,4);
        scatter(first_obj,second_obj,'filled','DisplayName',num2str(1))
        
        legend
        drawnow
        hold off
    end
           
end



