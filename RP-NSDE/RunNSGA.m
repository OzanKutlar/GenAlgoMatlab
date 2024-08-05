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

igd_arr = [];

hold on
while op.currentFE < gas.maxFE
    tic

    %--VARIATION
    offspring = variation_generic(pop);

    %--EVALUATION
    [offspring, fit_array_O] = evaluate(offspring);

    %SPEA Functions(strength, raw fitness, density, nondomsorting())

    % delete nonelits
    %--SURVIVOR
    [pop, fit_array_P] = survivor_generic(pop, offspring, fit_array_P, fit_array_O);
    fprintf('Current FE: %d \n',op.currentFE);
    fprintf('Best Fitness %.3f ', fit_array_P(1,1));
    fprintf('\n');
    disp(pop(1,:));
    fprintf('\n');

    igd_arr(1, end + 1) = igd(fit_array_P(:, 1:gas.n_ObjectiveFunctions), get_pf(op.name, gas.n_individuals));

    first_obj = fit_array_P(:,1);
    second_obj= fit_array_P(:,2);
    third_obj= fit_array_P(:,3);
    %figure
    clf
    subplot(2,1,1);
    if op.numberOfObjectives == 2
        scatter(first_obj,second_obj,'filled','DisplayName',strcat("Function evaluations: ", num2str(op.currentFE)));
        legend
    end
    if op.numberOfObjectives == 3
        scatter3(first_obj,second_obj, third_obj,'filled','DisplayName', strcat("Function evaluations: ", num2str(op.currentFE)));
        legend
    end
    if op.numberOfObjectives > 3
        plot(fit_array_P(:,1:gas.n_ObjectiveFunctions)');
    end
    subplot(2,1,2);
    plot(igd_arr, '--');
    xlabel('Generations');
    ylabel('IGD');
    xline(width(igd_arr), '-r', strcat('Current IGD : ', num2str(igd_arr(end))));
    axis padded
    % Added for continious figure
    drawnow
    %hold off
    toc
end

pareto.name = op.name;
pareto.data = fit_array_P(:, 1:gas.n_ObjectiveFunctions);
pareto.N = gas.n_individuals;

counter = 1;
while isfile("result" + counter + ".mat")
    counter = counter + 1;
end
save("result" + counter + ".mat", "pareto");
