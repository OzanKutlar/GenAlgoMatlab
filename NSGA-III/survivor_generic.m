function [nextGenPop, fit_array_NGP] = survivor_generic(pop, offspring, fit_array_P, fit_array_O)
%UNTITLED7 Summary of this function goes here

global op;  % optimization problem
global gas; % genetic algorithm settings

rankIndex=gas.n_ObjectiveFunctions+2;%rank ındex
distanceIndex=gas.n_ObjectiveFunctions+3;%crowding distance index
fit_array_O(:,rankIndex) = 0;
fit_array_O(:,distanceIndex) = 0;
Index=gas.n_ObjectiveFunctions+1;

[nextGenPop, fit_array_NGP] = elitistSurvivalFull(pop, offspring, fit_array_P, fit_array_O);


    function [nextGenPop_final, fit_array_NGP] = elitistSurvivalFull(pop, offspring, fit_array_P, fit_array_O)
        nextGenPop = zeros(gas.n_individuals,gas.n_variables);    % declare a static array of chromosomes filled with zeros
        fit_array_NGP = zeros(gas.n_individuals*2,size(fit_array_P,2));                  % array containing fitness for each individual of the new population

        nextGenPop(1:gas.n_individuals,:) = pop;
        nextGenPop(gas.n_individuals+1:gas.n_individuals*2,:) = offspring;

        fit_array_O(:,Index) = fit_array_O(:,Index) + gas.n_individuals;

        fit_array_NGP(1:gas.n_individuals,:) = fit_array_P;
        fit_array_NGP(gas.n_individuals+1:gas.n_individuals*2,:) = fit_array_O;


        fit_array_NGP = nonDomSortingGeneric(fit_array_NGP);
        [fit_normalized, reference_directions] = normalize(fit_array_NGP);
        [assosiations, reference_assosiations] = assosiate(fit_normalized, reference_directions);
        fit_array_NGP = niching(fit_array, reference_assosiations, assosiations);
    end

end