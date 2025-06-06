function assosiations = assosiate(normalizedfitArray, reference_points, pop)
    assosiations(height(reference_points) + 1) = struct('count', [], 'pop', []);
    assosiations(height(reference_points) + 1) = [];
    for i = 1:height(normalizedfitArray)
        point = normalizedfitArray(i, :);
        shortest.index = 1;
        shortest.original = i;
        shortest.dist = calculatePointToLineDistance(reference_points(1, :), point);
        for j = 2:height(reference_points)
            dist = calculatePointToLineDistance(reference_points(j, :), point);
            if(shortest.dist > dist)
                shortest.dist = dist;
                shortest.index = j;
            end
        end
        if(isempty(assosiations(shortest.index).count))
            assosiations(shortest.index).count = 1;
            assosiations(shortest.index).pop(width(pop) + 1) = struct('position', [], 'dist', []);
            assosiations(shortest.index).pop(width(pop) + 1) = [];
        end
        assosiations(shortest.index).pop(assosiations(shortest.index).count).position = pop(i);
        assosiations(shortest.index).pop(assosiations(shortest.index).count).dist = shortest.dist;
        assosiations(shortest.index).count = assosiations(shortest.index).count + 1;
    end
    for i = 1:width(assosiations)
        if(isempty(assosiations(i).count))
            assosiations(i).count = 0;
        end
    end
end


function distance = calculatePointToLineDistance(reference, point) 
    % This function calculates the distance between a point and a line in n-dimensional space.
    %
    % Inputs:
    % - lineEquation: A structure containing the following fields:
    %   - point: A point on the line (vector)
    %   - direction: The direction vector of the line (vector)
    % - point: A vector representing the coordinates of the point
    %
    % Output:
    % - distance: The shortest distance between the point and the line
    
    % Extract the point on the line and the direction vector from the line equation
    pointOnLine = zeros(1, width(reference));
    directionVector = reference;
    
    % Ensure the input point and line point have the same dimensions
    if width(pointOnLine) ~= width(point) || width(directionVector) ~= width(point)
        error('All points must have the same number of dimensions');
    end
    
    % Calculate the vector from the point on the line to the given point
    vectorToPoint = point - pointOnLine;
    
    % Project the vectorToPoint onto the direction vector
    projectionLength = dot(vectorToPoint, directionVector) / norm(directionVector);
    projectionVector = projectionLength * directionVector / norm(directionVector);
    
    % Calculate the orthogonal vector from the point to the line
    orthogonalVector = vectorToPoint - projectionVector;
    
    % The distance is the norm of the orthogonal vector
    distance = norm(orthogonalVector);
end