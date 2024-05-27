function [assosiations, reference_assosiations] = assosiate(normalizedfitArray, reference_points)
    assosiations = zeros(height(normalizedfitArray), 1);
    reference_assosiations = zeros(height(reference_points), 1);
    for i = 1:height(normalizedfitArray)
        point = normalizedfitArray(i, :);
        shortest.index = 1;
        shortest.dist = calculatePointToLineDistance(reference_points(1), point);
        for j = 2:height(reference_points)
            dist = calculatePointToLineDistance(reference_points(j), point);
            if(shortest.dist > dist)
                shortest.dist = dist;
                shortest.index = j;
            end
        end
        assosiations(i) = shortest;
        reference_assosiations(j) = reference_assosiations(j) + 1;
    end
end


