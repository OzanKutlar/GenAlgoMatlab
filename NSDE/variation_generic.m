function [U] = variation_generic(P, matPool)
%UNTITLED6 Summary of this function goes here
global op;  % optimization problem
global gas; % genetic algorithm settings

% declare a static array of chromosomes filled with zeros
U = zeros(gas.n_individuals, gas.n_variables);

F = 0.85;

for i = 1:gas.n_individuals
    %% Mutation
    Candidates = [1:i-1 i+1:gas.n_individuals];    % Ensuring that current member is not partner
    idx = Candidates(randperm(gas.n_individuals - 1, 3)); % Selection of three random partners
    X1 = P(idx(1), :);              % Randomly selected solution 1
    X2 = P(idx(2), :);              % Randomly selected solution 2
    X3 = P(idx(3), :);              % Randomly selected solution 3

    %% Crossover
    for j = 1:gas.n_variables
        U(i, j) = max(min(P(i, j) + 1 * (X3(j) - P(i, j)) + F * (X1(j) - X2(j)), op.bounds(2)), op.bounds(1));
    end
end

end