% Add a penalty factor to infeasible solutions (degrade their fitness).
%
% INPUT:
% 'chrom' is the chromosome [t+1 x n+4] to be evaluated (extra genes should not be empty)
% 'fit_array' 
% 'draw_plot' is a boolean flag, true if you want to plot the segments from targets (currently not used, but it might be useful in the future?)
%
% OUTPUT:
% 'fit_array' 
function [fit_array] = checkConstraints(pop, fit_array)
    global op;  % optimization problem
    global gas; % genetic algorithm settings

    switch gas.penalty_method
        case 'static'
            for i=1:gas.n_individuals
                index = fit_array(i,gas.fitIdx.id);
                fit_array(i,gas.fitIdx.pen) = calculateStaticPenalty(pop(:,:,index),[10 10 10 100 10]);
                if gas.ranking_method == "penalty"
                    fit_array(i,gas.fitIdx.ik) = fit_array(i,gas.fitIdx.ik) + fit_array(i,gas.fitIdx.pen);
                end
            end
%         case 'deb'
%             for i=1:gas.n_individuals
%                 index = fit_array(i,6);
%                 fit_array(i,2) = calculateStaticPenalty(pop(:,:,index),[1 1 1 1]);   
%             end
%             fit_array = addDebsPenalty(fit_array);
        otherwise
                error('Unexpected Constraint Handling Method.');
    end
    
end



%--------------DEB'S PENALTY METHOD--------------            
function [fit_array] = addDebsPenalty(fit_array)          
    global op;  % optimization problem
    global gas; % genetic algorithm settings

    % get the worst feasible solution's fitness
    worstFit = 0;
    bestFit = fit_array(1, 1);
    areThereFeasibleSolutions = false;
    for i = 1:1:gas.n_individuals
        if fit_array(i, 2) == 0 % if it is feasible
            if worstFit < fit_array(i, 1)
                worstFit = fit_array(i, 1);
                areThereFeasibleSolutions = true;
            end
        end
        if bestFit > fit_array(i, 1)
            bestFit = fit_array(i, 1);
        end
    end
    
    % if there are no feasible solutions, then we should get the best of the unfeasible solutions as baseline
    if areThereFeasibleSolutions == false
        worstFit = bestFit;
    end
    
    % add penalty
    for i = 1:1:gas.n_individuals
        if(fit_array(i, 2) ~= 0)    % if it is unfeasible    
            fit_array(i,3) = worstFit + fit_array(i, 2);
            fit_array(i,3) = fit_array(i,3) + fit_array(i, 1); % this part is not in Deb's formulation, but without it the ranking algorithm might not work!
        end
    end
end
