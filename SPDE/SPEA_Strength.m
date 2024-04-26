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
global gas;
global op;
for i = 1:height(fit_array)
    %declare a counter which count every solution j that is dominated by solution i
    counter = 0;
    for j = 1:height(fit_array)
        if i == j
            continue;
        end
        if dominates(fit_array(i,1:op.numberOfObjectives),fit_array(j,1:op.numberOfObjectives),gas.isMin,gas.onlyStrictlyDominance) % if j is dominated by i (in case of Min--Min problem)
            counter = counter + 1;
        end
    end
    fit_array(i,gas.strengthIndex)=counter; % assign strength to index 4
end
end