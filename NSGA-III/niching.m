function [newFit] = niching(fit_array, reference_assosiations, assosiations)
    global gas;

    newFit = zeros(gas.n_individuals, gas.n_ObjectiveFunctions + 3);
    indx = 1;

    while true
        if indx > gas.n_individuals
            break;
        end

        smallest = 1;
        for i = 2:height(reference_assosiations)
            if (reference_assosiations(i) ~= 0 && reference_assosiations(i) < reference_assosiations(smallest)) || reference_assosiations(smallest) == 0
                smallest = i;
            end
        end
    
        for i = 1:width(assosiations)
            if reference_assosiations(smallest) == 0 || indx > gas.n_individuals
                break;
            end
    
            if assosiations(i).index == smallest
                newFit(indx, :) = fit_array(assosiations(i).original, :);
                indx = indx + 1;
                reference_assosiations(smallest) = reference_assosiations(smallest) - 1;
            end
        end
    end
end
    

