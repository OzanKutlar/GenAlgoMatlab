% Evaluate the distances sorted for finding k-th nearest solution to each
% individual
%
% INPUT: 
% 'fit_array_archive' contains the fitness of each individual in the population of elites,
% the index of the individual in the array 'pop', strength of the
% individuals, raw fitness of the individuals, and density of the
% individuals
%
% OUTPUT: 
% 'distances' which are the distance of each individual from the k-closest individual

function [distances] = distances_k(fit_array_archive)
% declare a distance array which contains the distances of each individual to
% all other individuals
global op;
distances = zeros(size(fit_array_archive,1),size(fit_array_archive,1));
for i = 1:size(fit_array_archive,1)
    for j = 1:size(fit_array_archive,1)
        total_dist = 0;
        for k= 1:op.numberOfObjectives
            dist = ((fit_array_archive(i,k) - fit_array_archive(j,k)) / (max(fit_array_archive(:,k)) - min(fit_array_archive(:,k))))^2;
            total_dist = dist + total_dist;
        end
        distances(i,j) = sqrt(total_dist);
    end
end

% sort the distances for finding k-th nearest solution to each
% individual
for i = 1:size(fit_array_archive,1)
    distances(:,i) = sort(distances(:,i));
end
distances(1,:)=[];
end

