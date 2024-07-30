function [fit_array] = nonDomSortingGeneric(fit_array)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global gas

index=gas.n_ObjectiveFunctions+1; %index



rankIndex=gas.n_ObjectiveFunctions+2; %rank index
tempIndex = gas.n_ObjectiveFunctions+3;
temp_fit_array = sortrows(fit_array, 1);
rank = 1;
added = 1;
while ~isempty(temp_fit_array) % N (LogN)  * non-dominated layer sayısı
    temp_fit_array(:, tempIndex) = 1:height(temp_fit_array);
    nonDomLayer = recursiveNDS(temp_fit_array(:, :), 1:index - 1);
    nonDomLayer(:, rankIndex) = rank;

    removed = 0;
    for i = 1:height(nonDomLayer)
        temp_fit_array(nonDomLayer(i, tempIndex) - removed, :) = [];
        removed = removed + 1;
    end

    nonDomLayer(:, tempIndex) = 0;
    fit_array(added:added + height(nonDomLayer) - 1, :) = nonDomLayer(:, :);
    added = added + height(nonDomLayer);
    rank = rank + 1;
end
end

function result = recursiveNDS(pop, useIndex)
    hPop = height(pop);
    if(hPop == 1)
        result = pop;
        return;
    end
    halfwayPoint = bitshift(hPop, -1);
    left = recursiveNDS(pop(1:halfwayPoint, :), useIndex);
    right = recursiveNDS(pop(halfwayPoint + 1:hPop, :), useIndex);
    
    removed = [0, 0];
    if(~isempty(left) && ~isempty(right))
        for i = 1:height(left)
            removed(2) = 0;
            for j = 1:height(right)
                if(i - removed(1) == 0 || j - removed(2) == 0)
                    break;
                end
                if(all(left(i - removed(1), useIndex) <= right(j - removed(2), useIndex)))
                    if(any(left(i - removed(1), useIndex) < right(j - removed(2), useIndex)))
                        right(j - removed(2), :) = [];
                        removed(2) = removed(2) + 1;
                    end
                elseif all(left(i - removed(1), useIndex) >= right(j - removed(2), useIndex))
                    if(any(left(i - removed(1), useIndex) > right(j - removed(2), useIndex)))
                        left(i - removed(1), :) = [];
                        removed(1) = removed(1) + 1;
                    end
                end
            end
            if(i - removed(1) == 0 || j - removed(2) == 0)
                break;
            end
        end
    end
    result = vertcat(left, right);
end

function isDominated = checkDom(pos, pareto)
    isDominated = false;
    for i = 1:height(pareto)
        if(all(pareto(i, :) <= pos) && any(pareto(i, :) < pos))
            isDominated = true;
            break;
        end
    end
end