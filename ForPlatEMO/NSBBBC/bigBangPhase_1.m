function [temp_pop] = bigBangPhase_1(cMass,t)
    global bbbcs;
    temp_pop = zeros(bbbcs.N,bbbcs.n_variables);
    for i=1:1:size(cMass,1)
        for j=1:1:bbbcs.k
            for l=1:1:bbbcs.n_variables
            r1 = -1 + (1--1)*rand();
            temp_pop((i-1)* bbbcs.k +j,l) = cMass(i,l) + ((bbbcs.bounds(l,2) - bbbcs.bounds(l,1))*r1)/t;
            temp_pop((i-1)* bbbcs.k +j,l) = max(min(temp_pop((i-1)* bbbcs.k +j,l), bbbcs.bounds(l,2)), bbbcs.bounds(l,1));
            end
        end
    end
end