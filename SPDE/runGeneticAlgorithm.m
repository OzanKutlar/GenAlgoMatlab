% Runs the Genetic Algorithm
%
% INPUT: none
%
% OUTPUT: 
% 'pop_archive' is the population of elites at the last generation of the algorithm 
% 'fit_array_archive', is a matrix with 'fitness values','index in the pop array', 'strength', 'raw fitness', 'density', 'fitness values composed of the summation of raw_fitness and density' 
function [pop_archive, fit_array_archive] = runGeneticAlgorithm()
    global op;  % optimization problem
    global gas; % genetic algorithm settings
    
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
    fit_array_archive = zeros(gas.n_archive,gas.fitArraySize);
    pop_archive = zeros(gas.n_archive,op.numberOfDecisionVar);

    %--EVALUATION
    [pop, fit_array_P] = evaluate(pop);
    fit_array_P = SPEA_Strength(fit_array_P);
    fit_array_P = SPEA_Raw_Fitness(fit_array_P);
    [fit_array_P] = SPEA_Density(fit_array_P);
    fit_array_P(:,gas.lastFitnessIndex) = fit_array_P(:,gas.rawFitnessIndex) + fit_array_P(:,gas.densityIndex); % Fitness value

    %--SURVIVOR FOR NON_ELITES REMOVAL
    fit_array_P = sortrows(fit_array_P,gas.lastFitnessIndex,"ascend");
    fit_array_archive = fit_array_P(fit_array_P(:,gas.lastFitnessIndex) < 1, :); % non-dominated solutions
    [fit_array_archive] = Survival_SPEA2(fit_array_archive, fit_array_P);
   
    for i = 1:gas.n_archive
        for j = 1:op.numberOfDecisionVar
            pop_archive(i,j) = pop(fit_array_archive(i,gas.solutionIndex),j); % update the pop archive 
        end
    end
    for i=1:gas.n_archive
        fit_array_archive(i,gas.solutionIndex)=i;  % update the indices
    end
    
    %--ITERATIONS
    gen = 0;
    igd_arr = [];
    while op.currentFE < gas.maxFE
        gen = gen + 1;

        %--SELECTION
        matPool = selection(fit_array_archive);   % passing to selection only rank fitness and pop-related id
          
        %--VARIATION
        offspring = variation(pop_archive, matPool); % only performed on the archive to have individuals in size of population
        %--EVALUATION
        [offspring, fit_array_O] = evaluate(offspring); % evaluation of offspring
         
        %--SURVIVOR 
        [pop_archive, fit_array_archive] = survivor(pop_archive, offspring, fit_array_archive, fit_array_O);

        % Visualize population
        % Change This If there is more than 2 objective
        first_obj = fit_array_archive(:,1);
        second_obj= fit_array_archive(:,2);
        third_obj= fit_array_archive(:,3);

        igd_arr(1, end + 1) = igd(fit_array_archive(:, 1:gas.n_ObjectiveFunctions), get_pf(op.name, gas.n_individuals));
        fprintf('Current FE: %d/%d \n',op.currentFE, gas.maxFE);
        
        %figure
        clf
        subplot(2,1,1);
        if op.numberOfObjectives == 2
            scatter(first_obj,second_obj,'filled','DisplayName',strcat("Function evaluations: ", num2str(op.currentFE)));
        end
        if op.numberOfObjectives == 3
            scatter3(first_obj,second_obj, third_obj,'filled','DisplayName', strcat("Function evaluations: ", num2str(op.currentFE)));
        end
        legend

        subplot(2,1,2);
        plot(igd_arr);
        xlabel('Generations');
        ylabel('IGD');
        xline(width(igd_arr), '-r', strcat('Current IGD : ', num2str(igd_arr(end))));
        axis padded
        
        % Added for continious figure
        drawnow
        %hold off

    end  % place a breakpoint here as you run the algorithm to pause, and check how the individuals are evolving by plotting the best one with 'drawProblem2D(decodeIndividual(pop(:,:,1)))'
    
    disp("Finished!");
fprintf('Convergence Score: %d \n', sum(igd_arr));
end
