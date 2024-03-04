% Evaluate the distances sorted for finding k-th nearest solution to each
% individual
%
% INPUT: 
% 'pop' contains the fitness of each individual in the population of elites,
% the index of the individual in the array 'pop', strength of the
% individuals, raw fitness of the individuals, and density of the
% individuals
%
% OUTPUT: 
% 'distances' which are the distance of each individual from the k-closest individual

function [distances] = distances_k(pop)
% declare a distance array which contains the distances of each individual to
% all other individuals
global bbbcs;
distances = zeros(size(pop,1),size(pop,1));

for i = 1:size(pop,1)
    for j = 1:size(pop,1)
        total_dist = 0;
        for k = 1:bbbcs.numberOfObjectives
            dist = ((pop(i,bbbcs.n_variables + k) - pop(j,bbbcs.n_variables + k)) / (max(pop(:,bbbcs.n_variables + k)) - min(pop(:,bbbcs.n_variables + k))))^2;
            total_dist= total_dist + dist;
        end
        distances(i,j) = sqrt(total_dist);
    end
end

% sort the distances for finding k-th nearest solution to each
% individual
for i = 1:size(pop,1)
    distances(:,i) = sort(distances(:,i));
end
distances(1,:)=[];
end

