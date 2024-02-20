% Big Bang phase is used to create a new generation around the cMass
%
% INPUT:
% 'cMass' is the center of mass
% 't'
% 'pop' is the current population
%
% OUTPUT:
% 'arch' is the new population around the cMass
function [arch] = bigBangPhase_1(cMass,t,pop)
global bbbcs;
temp_pop = zeros(1,bbbcs.solutionIndex);
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
%--EVALUATION
pop = SPEA_Strength(pop);
pop = SPEA_Raw_Fitness(pop);
pop = SPEA_Density(pop);
pop(:,bbbcs.lastFitnessIndex) = pop(:,bbbcs.rawFitnessIndex) + pop(:,bbbcs.densityIndex);
for i=1:height(pop)
    pop(i,bbbcs.solutionIndex) = i;
end
%--SURVIVOR FOR NON_ELITES REMOVAL
pop = sortrows(pop,bbbcs.lastFitnessIndex,"ascend");
arch = zeros(1,bbbcs.solutionIndex);
arch = pop(pop(:,bbbcs.lastFitnessIndex) < 1, :); % non-dominated solutions
arch = Survival_SPEA2(arch, pop);

for i=1:bbbcs.N
    arch(i,bbbcs.solutionIndex)=i;  % update the indices
end

end