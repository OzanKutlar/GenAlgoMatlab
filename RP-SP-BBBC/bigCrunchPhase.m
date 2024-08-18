% Big Crunch phase is used to find the new center of mass around the best
% individuals
%
% INPUT: 
% 'pop' is the current population
%
% OUTPUT: 
% 'cMass' is the new center of mass 

function [cMass] = bigCrunchPhase(pop, setting)
    switch setting
        case 'eq1'
            cMass = bigCrunchPhase_eq1(pop);
        case 'eq2'
            cMass = bigCrunchPhase_eq2(pop);
    end
end

function [cMass] = bigCrunchPhase_eq1(pop)
global bbbcs;

    cMass = pop(pop(:,bbbcs.lastFitnessIndex) < 1,1:bbbcs.n_variables);
    
end

function [cMass] = bigCrunchPhase_eq2(pop)
    global bbbcs
    [W, bbbcs.n_cmass] = UniformPoint(bbbcs.n_cmass, bbbcs.numberOfObjectives);
    cosine = 1 - pdist2(W,W,'cosine');
    cosine(logical(eye(length(cosine)))) = 0;
    theta  = max(min(acos(cosine),[],2));
    QObj       = ObjectiveNormalization(pop);
    [Ei,Angle] = Associate(QObj,W);
    FV         = FitnessAssignment(Ei,QObj,Angle,theta);
    cMass = EnvironmentalSelection(pop,Ei,FV);
end    
