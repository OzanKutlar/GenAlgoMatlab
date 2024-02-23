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
global bbbcs;
for i=1:height(fit_array)
    rawFitness=0;
    for j=1:height(fit_array)
        % if i is dominated by j 
        if dominates(fit_array(j,bbbcs.n_variables + 1: bbbcs.n_variables + bbbcs.numberOfObjectives),fit_array(i,bbbcs.n_variables + 1: bbbcs.n_variables + bbbcs.numberOfObjectives),bbbcs.isMin,false)
            rawFitness=rawFitness+fit_array(j,bbbcs.strengthIndex);
        end
        fit_array(i,bbbcs.rawFitnessIndex)=rawFitness; % assign strength to index 7
    end

end



