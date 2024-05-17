% The hyperVolume indicator measures the volume (in the objective space)
% that is weakly dominated by an approximate set of pareto_front.
% It check the diversity among the obtained non-dominated solutions and
% the proximity of the obtained non-dominated solutions to the Pareto-optimal.
%
% INPUT:
%'pareto_front'
%
% OUTPUT:
% hyperVolume: it represents the space covered by the set of non-dominated solutions.

function hyperVolume=hyper2(input_matrix, isMin)
    pareto_front = normalizeMatrix(input_matrix);

    for i = 1:width(isMin)
        pareto_front(:, i) = pareto_front(:, i) * isMin(i);
    end

    % Number of pareto_front
    n = size(pareto_front, 1);
    % Number of objectives
    m = size(pareto_front, 2);
    
    reference_point = ones(1,m) * 1.1;
    
    % Monte Carlo approximation
    N = 1e6; % number of random samples
    counter = 0;
    
    for i = 1:N
        % Generate a random point in the objective space
        random_point = rand(1, m) .* reference_point;
        % Check if the random point is dominated by any of the pareto_front
        % in the set
        for j = 1:n
            if all(pareto_front(j, :) <= random_point) && any(pareto_front(j, :) < random_point)
                counter = counter + 1;
                break;
            end
        end
    end
    hyperVolume = prod(reference_point) * (counter / N);
end

function normalizedMatrix = normalizeMatrix(matrix)
    length = height(matrix);
    normalizedMatrix = zeros(length, width(matrix));
    for i = 1:length
        maxValue = max(matrix(:,i)); % Mean of all elements
        minValue = min(matrix(:,i));   % Standard deviation of all elements
        normalizedMatrix(:,i) = (matrix(:,i) - minValue) / (maxValue - minValue);
    end
end

