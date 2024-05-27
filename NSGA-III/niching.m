function [newPop] = niching(fit_array, reference_assosiations, assosiations)
    global g;
    newPop = zeros(); 
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

    newPop(end, :) = fit_array(nearestPoint.index, :);
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
    pointOnLine = zeros(width(reference));
    directionVector = reference;
    
    % Ensure the input point and line point have the same dimensions
    if length(pointOnLine) ~= length(point) || length(directionVector) ~= length(point)
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
