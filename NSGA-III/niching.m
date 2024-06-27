function [point, fit_temp] = niching(fit_temp, reference_assosiations, assosiations, k)
    global gas;
        smallest = inf;
        index = 0;
        for i = 1:width(assosiations)
            if isempty(assosiations(i).dist)
                assosiations(i).dist = 0;
            end
            if assosiations(i).index == k && assosiations(i).dist < smallest
                index = assosiations(i).original;
                smallest = assosiations(i).dist;
            end
        end
        if index == 0
            index = 1;
        end
        point = fit_temp(index, :);
        fit_temp(index, :) = [];
end
