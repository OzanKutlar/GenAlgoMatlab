% Perform the Raw Fitness operation which gives the summation of the strength of the
% individuals dominating each individual. High value of raw fitness means
% that the individual is dominated by many solutions, raw fitness = 0 means
% that the individual is a non-dominated solution.
%
% INPUT:
% 'fit_array' contains the fitness of each individual in the population,
% the index of the individual in the array 'pop', and strength of the
% individuals
%
% OUTPUT:
% 'fit_array' contains the fitness of each individual in the population,
% the index of the individual in the array 'pop', strength of the
% individuals and raw fitness of the individuals

function[fit_array] = SPEA_Raw_Fitness(fit_array)
global gas;

for i=1:height(fit_array)
    rawFitness=0;
    for j=1:height(fit_array)
        if i == j
            continue;
        end
        % if i is dominated by j (in case of Min--Min problem)
        if dominates(fit_array(j,1:gas.numberOfObjectives),fit_array(i,1:gas.numberOfObjectives),gas.isMin,gas.onlyStrictlyDominance)
            rawFitness=rawFitness+fit_array(j,gas.strengthIndex);
        end
        fit_array(i,gas.rawFitnessIndex)=rawFitness; % assign strength to index 5
    end

end



