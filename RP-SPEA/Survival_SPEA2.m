% Perform the SPEA2 Survival operation to keep fit_array_archive in archive size
%
% INPUT: 
% 'fit_array_archive' contains the fitness of each individual in the population of elites and the index of the individual in the array 'pop_archive'
% 'fit_array_P' contains the fitness of each individual in the population and the index of the individual in the array 'pop'
%
% OUTPUT: 
% 'fit_array_archive' is the non-dominated solutions which are basically 
% the population of elites in size of archive

function [fit_array_archive] = Survival_SPEA2(fit_array_archive, fit_array_P)
global gas;

if size(fit_array_archive,1) == gas.n_archive
    return;

elseif size(fit_array_archive,1) < gas.n_archive
    %fill fit_array_archive with dominated solutions
    n_dominated = gas.n_archive - size(fit_array_archive,1);
    fit_array_archive = [fit_array_archive; fit_array_P(size(fit_array_archive,1)+1:size(fit_array_archive,1)+n_dominated,:)];

else
    %filter some solutions with truncation operation until your 
    % fit_array_archive is in size of archive
    while size(fit_array_archive,1) > gas.n_archive
        fit_array_archive = truncation_operation(fit_array_archive);
    end
end

