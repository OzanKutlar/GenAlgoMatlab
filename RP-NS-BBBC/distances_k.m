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
distances = zeros(size(pop,1),size(pop,1));
first_obj_index = 3;
second_obj_index = 4;
for i = 1:size(pop,1)
    for j = 1:size(pop,1)

        dist_mag = ((pop(i,first_obj_index) - pop(j,first_obj_index)) / (max(pop(:,first_obj_index)) - min(pop(:,first_obj_index))))^2;
        dist_rel = ((pop(i,second_obj_index) - pop(j,second_obj_index)) / (max(pop(:,second_obj_index)) - min(pop(:,second_obj_index))))^2;
        distances(i,j) = sqrt(dist_rel + dist_mag);
    end
end

% sort the distances for finding k-th nearest solution to each
% individual
for i = 1:size(pop,1)
    distances(:,i) = sort(distances(:,i));
end
distances(1,:)=[];
end

