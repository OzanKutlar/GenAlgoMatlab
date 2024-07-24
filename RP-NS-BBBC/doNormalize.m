function [normalizedSwarm, reference_directions] = doNormalize(pareto)
    global op parameters; 

    n = op.numberOfObjectives + parameters.division - 1;
    r = parameters.division;
    H = factorial(n) / (factorial(r) * factorial(n - r));

    reference_directions = uniform_distribution(H, op.numberOfObjectives); % Creates a matrix with each value and a niching row next to it.
    normalizedSwarm = normalizeMatrixaaaa(pareto);
end

% Input : Number of points(N) and number of dimensions(M)
% Code from PlatEMO
function [W,N] = uniform_distribution(N,M)
    H1 = 1;
    while nchoosek(H1+M,M-1) <= N
        H1 = H1 + 1;
    end
    W = nchoosek(1:H1+M-1,M-1) - repmat(0:M-2,nchoosek(H1+M-1,M-1),1) - 1;
    W = ([W,zeros(size(W,1),1)+H1]-[zeros(size(W,1),1),W])/H1;
    if H1 < M
        H2 = 0;
        while nchoosek(H1+M-1,M-1)+nchoosek(H2+M,M-1) <= N
            H2 = H2 + 1;
        end
        if H2 > 0
            W2 = nchoosek(1:H2+M-1,M-1) - repmat(0:M-2,nchoosek(H2+M-1,M-1),1) - 1;
            W2 = ([W2,zeros(size(W2,1),1)+H2]-[zeros(size(W2,1),1),W2])/H2;
            W  = [W;W2/2+1/(2*M)];
        end
    end
    W = max(W,1e-6);
    N = size(W,1);
end

function normalizedMatrix = normalizeMatrixaaaa(matrix)
    global op; 
    length = op.numberOfObjectives;
    normalizedMatrix = zeros(height(matrix), length);
    for i = 1:length
        maxValue = max(matrix(:,i)); % Max of all elements
        minValue = min(matrix(:,i));   % Min of all elements
        normalizedMatrix(:,i) = (matrix(:,i) - minValue) / (maxValue - minValue);
    end
end