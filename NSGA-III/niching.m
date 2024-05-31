function [newPop] = niching(fit_array, reference_assosiations, assosiations)
    global gas;
    newPop = zeros(gas.n_individuals + 1, width(fit_array)); 
    newPop(end, 1) = 1;
    while true
        if(height(newPop) <= (newPop(end, 1)))
            break;
        end
        smallestReference.count = inf;
        smallestReference.index = 0;
        for i = 1:height(reference_assosiations)
            if(smallestReference.count > reference_assosiations(i) && reference_assosiations(i) ~= 0)
                smallestReference.count = reference_assosiations(i);
                smallestReference.index = i;
            end
        end
        
        if(height(newPop) - (newPop(end, 1)) >= smallestReference.count)
            for i = 1:width(assosiations)
                if(assosiations(i).index == smallestReference.index)
                    newPop(newPop(end, 1), :) = fit_array(i, :);
                    newPop(end, 1) = newPop(end, 1) + 1;
                end
            end
            reference_assosiations(smallestReference.index) = 0;
            if newPop(end, 1) == 100
                disp("OH NOO");
            end
            continue;
        end
        selectedAssosiations = zeros(height(newPop) - newPop(end, 1));
        for j = 1:height(newPop) - newPop(end, 1)
            
            nearestPoint.dist = inf;
            for i = 1:width(assosiations)
                if(assosiations(i).index == smallestReference.index && nearestPoint.dist > assosiations(i).dist) && ~ismember(i, selectedAssosiations)
                    nearestPoint.dist = assosiations(i).dist;
                    nearestPoint.index = i;
                end
            end
            selectedAssosiations(j) = nearestPoint.index;
            newPop(newPop(end, 1), :) = fit_array(nearestPoint.index, :);
            newPop(end, 1) = newPop(end, 1) + 1;
            reference_assosiations(smallestReference.index) = reference_assosiations(smallestReference.index) - 1;
        end
        if newPop(100, gas.n_ObjectiveFunctions+1) == 0
            disp("OH NOO");
        end
    end
    
    newPop(end, :) = [];
end
    

