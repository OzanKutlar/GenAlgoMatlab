function [pop, fit_array_P] = RunNSGA()

global gas; % genetic algorithm settings
global op;
% in case a funny user decides to have an odd number of idividuals in the population...
if mod(gas.n_individuals,2) ~= 0
    gas.n_individuals = gas.n_individuals + 1;
end

% a funnier user...
if gas.n_individuals <= 0
    gas.n_individuals = 1;
end



%--RANDOM INITIALIZATION
pop = initializeRandomPopulation();

%--EVALUATION
[pop, fit_array_P] = evaluate(pop);



fit_array_P = nonDomSortingGeneric(fit_array_P);
fit_array_P = crowding_distance_generic(fit_array_P);


hold on
for gen=1:1:gas.generations
    op.currentGen = gen;
    tic
    %--SELECTION
    matPool = Selection_Generic_NSGA(fit_array_P);   % passing to selection only rank fitness and pop-related id

    %--VARIATION
    offspring = variation_generic(pop, matPool);

    %--EVALUATION
    [offspring, fit_array_O] = evaluate(offspring);

    %SPEA Functions(strength, raw fitness, density, nondomsorting())

    % delete nonelits
    %--SURVIVOR
    [pop, fit_array_P] = survivor_generic(pop, offspring, fit_array_P, fit_array_O);
    fprintf('generation: %d \n',gen);
    fprintf('Best Fitness %.3f ', fit_array_P(1,1));
    fprintf('\n');
    disp(pop(1,:));
    fprintf('\n');

    
    first_obj = fit_array_P(:,1);
    second_obj= fit_array_P(:,2);
    third_obj= fit_array_P(:,3);
    %figure
    clf
    if op.numberOfObjectives == 2
        scatter(first_obj,second_obj,'filled','DisplayName',strcat("Generating gen : ", num2str(gen)))
    end
    if op.numberOfObjectives == 3
        scatter3(first_obj,second_obj, third_obj,'filled','DisplayName', strcat("Generating gen : ", num2str(gen)) )
    end
    legend
    
    % Added for continious figure
    drawnow
    %hold off
    toc
end

pareto.data = fit_array_P(:, 1:gas.n_ObjectiveFunctions);
save("result.mat", "pareto");



