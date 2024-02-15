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
distances = zeros(size(fit_array_archive,1),size(fit_array_archive,1));
first_obj_index = 1;
second_obj_index = 2;
for i = 1:size(fit_array_archive,1)
    for j = 1:size(fit_array_archive,1)

        dist_mag = ((fit_array_archive(i,first_obj_index) - fit_array_archive(j,first_obj_index)) / (max(fit_array_archive(:,first_obj_index)) - min(fit_array_archive(:,first_obj_index))))^2;
        dist_rel = ((fit_array_archive(i,second_obj_index) - fit_array_archive(j,second_obj_index)) / (max(fit_array_archive(:,second_obj_index)) - min(fit_array_archive(:,second_obj_index))))^2;
        distances(i,j) = sqrt(dist_rel + dist_mag);
    end
end

% sort the distances for finding k-th nearest solution to each
% individual
for i = 1:size(fit_array_archive,1)
    distances(:,i) = sort(distances(:,i));
end
distances(1,:)=[];
end

