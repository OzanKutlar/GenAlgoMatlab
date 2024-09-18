clc
clear

%% Problem settings
lb = [-100 -100 -100 -100 -100];   % Lower bound
ub = [100 100 100 100 100];   % Upper bound
prob = @sphere;       % Fitness function
objectives = 1;     % Objective count

%% Parameters for Differential Evolution
Np = 100;   % Population size
T = 100;    % Number of iterations
Pc = 0.8;   % Crossover probability
F = 0.85;   % Scaling factor

%% Starting of Differential Evolution
f = NaN(Np, objectives);    % Fitness value of the population
fu = NaN(Np, objectives);   % Fitness value of the new population
D = length(lb);             % Number of decision variables
U = NaN(Np, D);             % Trial solutions
P = repmat(lb, Np, 1) + repmat((ub - lb), Np, 1) .* rand(Np, D); % Initial population

for p = 1:Np
    f(p, :) = prob(P(p,:)); % Fitness of the initial population
end

if objectives ~= 1
    hold on
end

%% Iteration loop
for t = 1:T
    for i = 1:Np
        %% Mutation
        Candidates = [1:i-1 i+1:Np];    % Ensuring that current member is not partner
        idx = Candidates(randperm(Np - 1, 3)); % Selection of three random partners
        X1 = P(idx(1), :);              % Randomly selected solution 1
        X2 = P(idx(2), :);              % Randomly selected solution 2
        X3 = P(idx(3), :);              % Randomly selected solution 3
        V = X1 + F * (X2 - X3);         % Generating the donor vector

        %% Crossover
        del = randi(D, 1);              % Generating the random variable delta

        for j = 1:D
            if rand <= Pc || del == j % Check for donor vector or target vector
                U(i, j) = V(j);         % Accept variable from donor vector
            else
                U(i, j) = P(i, j);      % Accept variable from target vector
            end
        end
    end
    
    %% Bounding and Greedy Solution
    for j = 1:Np
        U(j, :) = min(ub, U(j, :));     % Bounding violating variables to upper bound
        U(j, :) = max(lb, U(j, :));     % Bounding violating variables to lower bound

        fu(j, :) = prob(U(j, :));       % Evaluating the fitness of the trial solution

        if all(fu(j, :) <= f(j, :)) && any(fu(j, :) < f(j, :)) % Greedy selection
            P(j, :) = U(j, :);          % Include the new solution in population
            f(j, :) = fu(j, :);         % Include the fitness functions value of the new solution
        end
    end
    
    if objectives == 2
        clf
        scatter(f(:, 1), f(:, 2), "filled");
        drawnow
    elseif objectives == 3
        clf
        scatter3(f(:, 1), f(:, 2), f(:, 3), "filled");
        drawnow
    end
end

if objectives == 1
    [bestfitness, ind] = min(f);
    bestsol = P(ind, :);

    disp(bestfitness);
    disp(bestsol);
end