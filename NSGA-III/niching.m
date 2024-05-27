function [newPop] = niching(fit_array, reference_assosiations, assosiations)
    global gas;
    newPop = zeros(gas.n_individuals + 1, width(fit_array)); 
    newPop(end, 1) = 1;
    while true
        if(height(newPop) - 1 <= (newPop(end, 1)))
            break;
        end
        smallestReference.count = inf;
        smallestReference.index = 0;
        for i = 2:height(reference_assosiations)
            if(smallestReference.count > reference_assosiations(i) && reference_assosiations(i) ~= 0)
                smallestReference.count = reference_assosiations(i);
                smallestReference.index = i;
            end
        end
        
        if(height(newPop) - (newPop(end, 1) + 1) >= smallestReference.count)
            for i = 1:height(assosiations)
                if(assosiations(i).index == smallestReference.index)
                    newPop(newPop(end, 1), :) = fit_array(i, :);
                    newPop(end, 1) = newPop(end, 1) + 1;
                end
            end
        end
        for j = 1:height(newPop) - (newPop(end, 1) + 1)
            nearestPoint.dist = inf;
            for i = 1:height(assosiations)
                if(assosiations(i).index == smallestReference.index && nearestPoint.dist > assosiations(i).dist)
                    nearestPoint.dist = assosiations(i).dist;
                    nearestPoint.index = i;
                end
            end
            newPop(newPop(end, 1), :) = fit_array(nearestPoint.index, :);
        end
    end
    
    newPop(end, :) = [];
end
    

