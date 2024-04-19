% Determines if one solution dominates (weakly or strongly) another solution in a multi-objective optimization problem.
%
% Parameters:
%   A: a column vector of size Mx1 representing the fitnesses of solution A in each objective, where M is the number of objectives.
%   B: a column vector of size Mx1 representing the fitnesses of solution B in each objective, where M is the number of objectives.
%   isMin: a column vector of size Mx1 specifying whether each objective is to be minimized (true) or maximized (false).
%   strong: a boolean indicating whether to consider strong dominance only and not weak dominance.
%   strong dominance is meaning A is better in all objectives than B
%   weak dominance is meaning A is better in at least one objective and not worse in all objectives
%
% Output:
%   result: true if solution A dominates or weakly dominates solution B, false otherwise.
%
function A_dominates_B = dominates(A, B, isMin, strong)
    % get the number of objectives
    M = numel(A);
    A_dominates_B = false;
    
    % get number of inputs if strong is not given set it to false as default
    numargs = nargin;
    if numargs == 3
        strong = false;
    end
    
    % if dominance is not strong, A is not worse than B in all objectives and A
    % is better in at least one objective
    if strong==false
        strictlyBetter=false;
        noWorse=true;
    
        % check if A dominates B
        for i = 1:M
            % for objectives to be minimized
            if isMin(i)
                if A(i)>B(i)
                    noWorse=false;
                end
                if(A(i)< B(i))
                    strictlyBetter=true;
                end
            else 
                % for objectives to be maximized
                if A(i)<B(i)
                    noWorse=false;
                end
                if(A(i)> B(i))
                    strictlyBetter=true;
                end
    
            end
    
        end
        % A is better in at least one objective and not worse in all objectives
        if noWorse==true && strictlyBetter==true
            A_dominates_B=true;
        end
    % Check for strong dominance meaning A is better in all objectives than B
    else
        A_dominates_B=true;
        for i=1:M
            % objectives to be minimized
            if isMin(i)
                if A(i)>=B(i)
                    A_dominates_B=false;
                end
            % objectives to be maximized
            else 
                if A(i) <=B(i)
                    A_dominates_B=false;
                end
            end
        end
    end
end


