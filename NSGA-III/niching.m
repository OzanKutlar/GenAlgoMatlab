function [fit_array] = niching(fit_array, reference_assosiations, assosiations)
    smallestReference.count = reference_assosiations(1);
    smallestReference.index = 1;
    for i = 2:height(reference_assosiations)
        if(smallestReference.count > reference_assosiations(i) && reference_assosiations(i) ~= 0)
            smallestReference.count = reference_assosiations(i);
            smallestReference.index = i;
        end
    end

    nearestPoint.dist = inf;
    for i = 1:height(assosiations)
        if(assosiations(i).index == smallestReference.index && nearestPoint.dist > assosiations(i).dist)
            nearestPoint.dist = assosiations(i).dist;
            nearestPoint.index = i;
        end
    end
    



end