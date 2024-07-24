function [pop]= bigBangPhase()
global bbbcs;
pop = zeros(bbbcs.N,bbbcs.solutionIndex);
for i=1:1:bbbcs.N
    for j = 1:1:bbbcs.n_variables
        pop(i,j) = bbbcs.bounds(j,1) + (bbbcs.bounds(j,2)-bbbcs.bounds(j,1))*rand();
    end
end
pop(:,bbbcs.n_variables+1:bbbcs.n_variables + bbbcs.numberOfObjectives) = evaluateIndividual(pop(:,1:bbbcs.n_variables));
end
