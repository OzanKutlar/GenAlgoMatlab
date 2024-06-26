function [nextGenPop, fit_array] = survivor_generic(pop, offspring, fit_array_P, fit_array_O)
%UNTITLED7 Summary of this function goes here

global op;  % optimization problem
global gas; % genetic algorithm settings

rankIndex=gas.n_ObjectiveFunctions+2;%rank ındex
distanceIndex=gas.n_ObjectiveFunctions+3;%crowding distance index
fit_array_O(:,rankIndex) = 0;
fit_array_O(:,distanceIndex) = 0;
Index=gas.n_ObjectiveFunctions+1;

[nextGenPop, fit_array] = elitistSurvivalFull(pop, offspring, fit_array_P, fit_array_O);


    function [nextGenPop_final, fit_array] = elitistSurvivalFull(pop, offspring, fit_array_P, fit_array_O)
        nextGenPop = zeros(gas.n_individuals,gas.n_variables);    % declare a static array of chromosomes filled with zeros
        fit_array_NGP = zeros(gas.n_individuals*2,size(fit_array_P,2));                  % array containing fitness for each individual of the new population

        nextGenPop(1:gas.n_individuals,:) = pop;
        nextGenPop(gas.n_individuals+1:gas.n_individuals*2,:) = offspring;

        fit_array_O(:,Index) = fit_array_O(:,Index) + gas.n_individuals;

        fit_array_NGP(1:gas.n_individuals,:) = fit_array_P;
        fit_array_NGP(gas.n_individuals+1:gas.n_individuals*2,:) = fit_array_O;


        fit_array_NGP = nonDomSortingGeneric(fit_array_NGP);
        fit_array = zeros(gas.n_individuals, gas.n_ObjectiveFunctions + 3);
        indx = 0;
        fit_temp = [];
        rank = 1;
        for i = 1:height(fit_array_NGP)
            if fit_array_NGP(i, gas.n_ObjectiveFunctions + 2) == rank
                fit_temp(end + 1, :) = fit_array_NGP(i, :);
            else
                if indx + height(fit_temp) == gas.n_individuals
                    fit_array(indx + 1:indx + height(fit_temp), :) = fit_temp;
                    break;
                elseif indx + height(fit_temp) > gas.n_individuals
                    [fit_normalized, reference_directions] = normalize(fit_temp);
                    [assosiations, reference_assosiations] = assosiate(fit_normalized, reference_directions);
                    fit_temp = niching(fit_temp, reference_assosiations, assosiations, gas.n_individuals - indx);
                    fit_array(indx + 1:indx + height(fit_temp), :) = fit_temp;
                    break;
                else
                    fit_array(indx + 1:indx + height(fit_temp), :) = fit_temp;
                    indx = indx + height(fit_temp);
                    rank = rank + 1;
                    fit_temp = [];
                end
            end
        end

        

        % fit_array_NGP = crowding_distance_generic(fit_array_NGP);
    	% rank_at_half = fit_array_NGP(gas.n_individuals,rankIndex);
        % fit_array_NGP(fit_array_NGP(:,rankIndex) == rank_at_half,:) = sortrows(fit_array_NGP(fit_array_NGP(:,rankIndex) == rank_at_half,:),distanceIndex,"descend");
        % fit_array_NGP(gas.n_individuals+1:gas.n_individuals*2,:) = [];


        nextGenPop_final = zeros(gas.n_individuals,gas.n_variables);
        for i=1:gas.n_individuals
            index = fit_array(i,Index);
            nextGenPop_final(i,:) = nextGenPop(index,:);
            fit_array(i,Index) = i;
        end
    end

end