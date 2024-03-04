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
    checkSize=size(pop(pop(:,bbbcs.rankIndex) == 1,1:bbbcs.n_variables),1);
    if checkSize < bbbcs.n_cmass
        cMass = pop(1:bbbcs.n_cmass,1:bbbcs.n_variables);
    else
        tempPop = pop(pop(:,bbbcs.rankIndex) == 1,:);
        tempPop=sortrows(tempPop, bbbcs.crowdingDistIndex,"descend");
        cMass=tempPop(1:bbbcs.n_cmass,1:bbbcs.n_variables);
    end
end

function [cMass] = bigCrunchPhase_eq2(pop)
    global bbbcs;
    sumFit = 0.0;
    sumFit_x1 = 0.0;
    sumFit_x2 = 0.0;
    for i=1:1:bbbcs.N
        sumFit = sumFit + pop(i,4);

        sumFit_x1 = sumFit_x1 + pop(i,4) * pop(i,1);
        sumFit_x2 = sumFit_x2 + pop(i,4) * pop(i,2);
    end
    cMass(1,1) = sumFit_x1 / sumFit;
    cMass(1,2) = sumFit_x2 / sumFit;
end    
