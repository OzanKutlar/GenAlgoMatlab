% Perform the density estimation as a decreasing function of the distance
% in objective space to the 𝑘-th nearest solution. It is used to
% discriminate between individuals having identical raw fitness values.
%
% INPUT:
%'fit_array' contains the fitness of each individual in the population,
% the index of the individual in the array 'pop', strength of the
% individuals and raw fitness of the individuals
%
% OUTPUT:
% 'fit_array' contains the fitness of each individual in the population,
% the index of the individual in the array 'pop', strength of the
% individuals, raw fitness of the individuals, and density of the
% individuals

function [fit_array] = SPEA_Density(fit_array)
    global bbbcs;
    global op;
    % declare a Density Array which contains the distances of each individual to
    % all other individuals
    densityArray = zeros(size(fit_array,1),size(fit_array,1));
    max_min_obj = zeros(op.numberOfObjectives,2);
    for m = 1:op.numberOfObjectives
        max_min_obj(m,1) = max(fit_array(:,bbbcs.n_variables + m));
        max_min_obj(m,2) = min(fit_array(:,bbbcs.n_variables + m));
    end
    for i = 1:size(fit_array,1)
        for j = 1:size(fit_array,1)
            overall_distance = 0;
            for m = 1:bbbcs.numberOfObjectives
                dist = ((fit_array(i,bbbcs.n_variables + m) - fit_array(j,bbbcs.n_variables + m)) / (max_min_obj(m,1) - max_min_obj(m,2)))^2;
                overall_distance = overall_distance + dist;
            end
            densityArray(i,j) = sqrt(overall_distance);
        end
    end
    
    % sort the Density Array for finding k-th nearest solution to each
    % individual
    for i = 1:size(fit_array,1)
        densityArray(:,i) = sort(densityArray(:,i));
    end
    
    % declare k as the square root of the sample size
    k = ceil(sqrt(size(fit_array,1)*2));
    
    % assign the density to index 8 according to density formula
    for i = 1:size(fit_array,1)
        fit_array(i,bbbcs.densityIndex) = 1 / (densityArray(k,i) + 2);
    end
end