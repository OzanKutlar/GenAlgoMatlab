% Perform the Strength operation which gives the number of solutions
% that each individual dominates
%
% INPUT: 
% 'fit_array' contains the fitness of each individual in the population and the index of the individual in the array 'pop'
%
% OUTPUT: 
% 'fit_array' contains the fitness of each individual in the population,
% the index of the individual in the array 'pop', and strength of the
% individuals

function [fit_array] = SPEA_Strength(fit_array)
global bbbcs;
for i = 1:height(fit_array)
    %declare a counter which count every solution j that is dominated by solution i
    counter = 0;
    for j = 1:height(fit_array)
        if i == j
            continue;
        end
        if dominates(fit_array(i,bbbcs.n_variables + 1: bbbcs.n_variables + bbbcs.numberOfObjectives),fit_array(j,bbbcs.n_variables + 1: bbbcs.n_variables + bbbcs.numberOfObjectives),bbbcs.isMin,false) % if j is dominated by i (in case of Min--Min problem)
            counter = counter + 1;
        end
    end
    fit_array(i,bbbcs.strengthIndex)=counter; % assign strength to index 6
end
end