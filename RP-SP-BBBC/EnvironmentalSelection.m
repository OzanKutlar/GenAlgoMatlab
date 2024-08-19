function Population = EnvironmentalSelection(Population,Ei,FV)
% The environmental selection of SPEA/R

%------------------------------- Copyright --------------------------------
% Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    global bbbcs op;
    Choose = [];
    while length(Choose) < bbbcs.n_cmass
        H = [];
        for i = unique(Ei)
            if i > 0
                Local = find(Ei==i);
                [~,q] = min(FV(Local));
                H     = [H,Local(q)];
            end
        end
        if op.currentFE >= bbbcs.maxFE
            if any(FV(H)<1)
                H = H(FV(H)<1);
            end
        end
        Ei(H) = -1;
        if length(Choose) + length(H) <= bbbcs.n_cmass
            Choose = [Choose, H];       
        else       
            [~,rank] = sort(FV(H));
            Choose   = [Choose,H(rank(1:bbbcs.n_cmass-length(Choose)))];
        end
    end
    Population = Population(Choose, :);
end