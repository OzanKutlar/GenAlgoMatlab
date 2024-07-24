% Perform the SPEA2 Survival operation to keep pop in archive size
%
% INPUT: 
% 'pop' contains the fitness of each individual in the population of elites and the index of the individual in the array 'pop_archive'
% 'fit_array_P' contains the fitness of each individual in the population and the index of the individual in the array 'pop'
%
% OUTPUT: 
% 'pop' is the non-dominated solutions which are basically 
% the population of elites in size of archive

function [pop] = Survival(pop)
global bbbcs;

if size(pop(pop(:,6)==1,:),1) == bbbcs.N
    return;

elseif size(pop(pop(:,6)==1,:),1) < bbbcs.N
    %fill pop with dominated solutions
    pop = pop(1:bbbcs.N,:);

else
    %filter some solutions with truncation operation until your 
    % pop is in size of archive
    while size(pop(pop(:,6)==1,:),1) > bbbcs.N
        pop = truncation_operation(pop(pop(:,6)==1,:));
    end
end

