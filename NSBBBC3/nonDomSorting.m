% Give rank to the individuals based on domination definition
function [pop] = nonDomSorting(pop)
global bbbcs;
temp_pop = pop;
for i = 1:size(pop,1)
    temp_pop(i,bbbcs.solutionIndex) = i;
end
rank = 1;
while ~isempty(temp_pop)
    P = [];
    for i = 1:height(temp_pop)
        counter = 0;
        for j = 1:height(temp_pop)
            if i == j
                continue
            end
           % if j dominates i break 
           if dominates(temp_pop(j,bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives),temp_pop(i,bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives),bbbcs.isMin,bbbcs.strongDominance)
               break
           else
               counter = counter + 1;
           end
           if counter == height(temp_pop) - 1
               P = [P,temp_pop(i,bbbcs.solutionIndex)];
           end
        end
    end
    if size(temp_pop,1) == 1
        P = temp_pop(1,bbbcs.solutionIndex);
    end
    for i = 1:length(P)
        pop(P(i),bbbcs.rankIndex) = rank;
    end
    for i = 1:length(P)
        temp_pop(temp_pop(:,bbbcs.solutionIndex) == P(i),:) = [];
    end
    rank = rank + 1;  
end
pop = sortrows(pop,bbbcs.rankIndex);
pop = crowding_distance_BBBC(pop);
end