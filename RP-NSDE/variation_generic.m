function [offspring] = variation_generic(pop, matPool)
    % offspring = current_to_rand_1(pop);
    offspring = rand_1_bin(pop);
end

function [offspring] = current_to_rand_1(pop)
% DE/current-to-rand/1 method

global op;  % optimization problem
global gas; % genetic algorithm settings

% declare a static array of chromosomes filled with zeros
offspring = zeros(gas.n_individuals, op.numberOfDecisionVar);

F = 0.85;

for i = 1:gas.n_individuals
    %% Mutation
    Candidates = [1:i-1 i+1:gas.n_individuals];    % Ensuring that current member is not partner
    idx = Candidates(randperm(gas.n_individuals - 1, 3)); % Selection of three random partners
    X1 = pop(idx(1), :);              % Randomly selected solution 1
    X2 = pop(idx(2), :);              % Randomly selected solution 2
    X3 = pop(idx(3), :);              % Randomly selected solution 3

    %% Crossover
    for j = 1:op.numberOfDecisionVar
        offspring(i, j) = max(min(pop(i, j) + 1 * (X3(j) - pop(i, j)) + F * (X1(j) - X2(j)), op.bounds(2)), op.bounds(1));
    end
end
end

function [offspring] = rand_1_bin(pop)
    % DE/rand/1/bin method

    global op;  % optimization problem
    global gas; % genetic algorithm settings

    % declare a static array of chromosomes filled with zeros
    offspring = zeros(gas.n_individuals, op.numberOfDecisionVar);

    F = 0.85;
    Pc = 0.8;

    for i = 1:gas.n_individuals
        %% Mutation
        Candidates = [1:i-1 i+1:gas.n_individuals];    % Ensuring that current member is not partner
        idx = Candidates(randperm(gas.n_individuals - 1, 3)); % Selection of three random partners
        X1 = pop(idx(1), :);              % Randomly selected solution 1
        X2 = pop(idx(2), :);              % Randomly selected solution 2
        X3 = pop(idx(3), :);              % Randomly selected solution 3
        V = X1 + F * (X2 - X3);         % Generating the donor vector

        %% Crossover
        del = randi(op.numberOfDecisionVar, 1);              % Generating the random variable delta

        for j = 1:op.numberOfDecisionVar
            if rand <= Pc || del == j % Check for donor vector or target vector
                offspring(i, j) = max(min(V(j), op.bounds(2)), op.bounds(1));         % Accept variable from donor vector
            else
                offspring(i, j) = pop(i, j);      % Accept variable from target vector
            end
        end
    end
end