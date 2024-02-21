function [pop] = bigBangPhase_1(cMass,t,pop)
global bbbcs;
temp_pop = zeros(1,bbbcs.solutionIndex);
    global bbbcs;
    for i=1:1:size(cMass,1)
        for j=1:1:bbbcs.k
            for l=1:1:bbbcs.n_variables
            r1 = -1 + (1--1)*rand();
            temp_pop((i-1)* bbbcs.k +j,l) = cMass(i,l) + ((bbbcs.bounds(l,2) - bbbcs.bounds(l,1))*r1)/t;

            temp_pop((i-1)* bbbcs.k +j,l) = max(min(temp_pop((i-1)* bbbcs.k +j,l), bbbcs.bounds(l,2)), bbbcs.bounds(l,1));
        end
        temp_pop((i-1)* bbbcs.k +j,bbbcs.n_variables+1:bbbcs.n_variables + bbbcs.numberOfObjectives) = evaluateIndividual(temp_pop((i-1)* bbbcs.k +j,1:bbbcs.n_variables));
        end
    end
    pop = [pop; temp_pop];
    pop = nonDomSorting(pop);
    pop=pop(1:bbbcs.N,:);
end