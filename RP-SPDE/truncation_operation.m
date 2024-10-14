% Perform truncation operation which iteratively remove individuals from
% fit_array_archive(t+1 (next generation)) until its size is equal to archive size and diversity is
% preserved
%
% INPUT: 
% 'fit_array_archive' is the non-dominated solution in size greater than 
% archive size
%
% OUTPUT: 
% 'fit_array_archive' is the non-dominated solutions which are basically 
% the population of elites which in size of archive

function [fit_array_archive] = truncation_operation(fit_array_archive)
[distances]= distances_k(fit_array_archive); % distances sorted for finding k-th nearest solution to each
% individual

for i=1:size(distances,1)
    minVal = min(distances(i,:)); % minimum value
    minIndices = find(distances(i, :) == minVal); % array of indices which has the minimum value

    % check if there is a tie (several individuals with minimum distance)
    if length(minIndices) == 1  % no tie
        fit_array_archive(minIndices,:)=[]; %remove the individual with min distance
        return;

    else  % a tie
        % check the next k's for the individuals in minIndices
        for j=i+1:size(distances,1)
            if distances(j, minIndices(1,1))~=distances(j,minIndices(1,2)) 
                min_2= min(distances(j,minIndices(1,1)),distances(j,minIndices(1,2)));
                if distances(j,minIndices(1)) == min_2
                    min_idx = minIndices(1);
                else
                    min_idx = minIndices(2);
                end
                fit_array_archive(min_idx,:)=[];
                return;
            else
                continue;
            end
        end
        fit_array_archive(minIndices(1,1),:)=[]; % the individuals are copy, remove first
        return;
    end
end
end

