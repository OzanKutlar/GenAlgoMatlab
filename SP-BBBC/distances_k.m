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
global op;
distances = zeros(size(pop,1),size(pop,1));
max_min_obj = zeros(bbbcs.numberOfObjectives,2);
for k= 1:op.numberOfObjectives
    max_min_obj(k,1) = max(pop(:,bbbcs.n_variables + k));
    max_min_obj(k,2) = min(pop(:,bbbcs.n_variables + k));
end

for i = 1:size(pop,1)
    for j = 1:size(pop,1)
        total_dist = 0;
        for k = 1:bbbcs.numberOfObjectives
            dist = (abs(pop(i,bbbcs.n_variables + k) - pop(j,bbbcs.n_variables + k)) / (max_min_obj(k,1) - max_min_obj(k,2)))^2;
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

