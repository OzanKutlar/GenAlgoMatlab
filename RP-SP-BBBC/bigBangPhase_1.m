function [pop] = bigBangPhase_1(cMass,t,pop)
    global bbbcs op;
    pop(1:height(cMass), :) = cMass;

    index = height(cMass) + 1;
    centerIndex = 0;
    lengthIndex = bbbcs.k;
    while index <= height(pop)
        if centerIndex == 0
            centerIndex = height(cMass);
        end
        for l=1:1:bbbcs.n_variables
            r1 = -1 + 2*rand();
            pop(index,l) = cMass(centerIndex,l) + ((bbbcs.bounds(l,2) - bbbcs.bounds(l,1))*r1)/t;
            pop(index,l) = max(min(pop(index,l), bbbcs.bounds(l,2)), bbbcs.bounds(l,1));
        end
        lengthIndex = lengthIndex - 1;
        if lengthIndex == 0
            centerIndex = centerIndex - 1;
            lengthIndex = bbbcs.k;
        end
        index = index + 1;
    end
    
    if(startsWith(op.name, "DTLZ"))
        pop(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives) = benchmark(pop(:, 1:bbbcs.n_variables));
    else
        index = height(cMass) + 1;
        centerIndex = 0;
        lengthIndex = bbbcs.k;
        while index <= height(pop)
            if centerIndex == 0
                centerIndex = height(cMass);
            end
            pop(index, bbbcs.n_variables+1:bbbcs.n_variables + bbbcs.numberOfObjectives) = evaluateIndividual(pop(index,1:bbbcs.n_variables));
            lengthIndex = lengthIndex - 1;
            if lengthIndex == 0
                centerIndex = centerIndex - 1;
                lengthIndex = bbbcs.k;
            end
            index = index + 1;
        end
    end
end