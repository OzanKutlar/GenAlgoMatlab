% Select individuals for reproduction
%
% INPUT:
% 'fit_array' is [n_individuals x 2] containing the fitness of each individual in the population and the index of the individual in the array 'pop'
%
% OUTPUT:
% 'matPool' is [n_individuals x 1] containing the indices of the individual selected for reproduction
%
% IMPORTANT ---> the indices in the mating pool refer to the individuals in the array 'pop'
function [matPool] = selection(fit_array)

global gas; % genetic algorithm settings

switch gas.selection_method
    case 'tournament'
        matPool = tournament(fit_array, 2);	% binary tournament selection
    case 'proportionate'
        matPool = proportionate(fit_array, true);	% fitness proportioante selection over rank
    otherwise
        error('Unexpected Selection Method.');
end
end

%--------------TOURNAMENT SELECTION--------------

function [matPool] = tournament(fit_array, k)
global gas; % genetic algorithm settings

matPool = zeros(gas.n_individuals,1);
for i=1:gas.n_individuals
    matPool(i) = getTournamentWinner(fit_array, k);
end
end

function [winner] = getTournamentWinner(fit_array, k)
global gas; % genetic algorithm settings

bestFit = 0;
winner = 0;
for j=1:k
    index = ceil((gas.n_individuals)*rand);
    if j==1
        bestFit = fit_array(index,7);
        winner = fit_array(index,3);
    else
        if bestFit > fit_array(index,7)
            bestFit = fit_array(index,7);
            winner = fit_array(index,3);
        end
    end
end
end

%--------------FITNESS PROPORTIONATE SELECTION--------------

function [matPool] = proportionate(fit_array, isMin)
global gas; % genetic algorithm settings

if isMin == true
    fit_array(:,1) = flip(fit_array(:,1));  % for minimization, rank must be flipped
end
s = sum(fit_array(:,1));

% calculate probability
for i = 1:1:gas.n_individuals
    if i==1
        fit_array(i,1) = fit_array(i,1)/s;
    else
        fit_array(i,1) = fit_array(i,1)/s + fit_array(i-1,1);
    end
end

% fill mating pool
matPool = zeros(gas.n_individuals,1);
for i = 1:1:gas.n_individuals
    r = rand();
    for j = 1:1:gas.n_individuals
        if fit_array(j,1) >= r
            matPool(i) = fit_array(j,2);
            break;
        end
    end
end

end