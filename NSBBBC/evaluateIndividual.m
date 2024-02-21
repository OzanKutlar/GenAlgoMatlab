
function [evaluatedIndividual] = evaluateIndividual(i)

evaluatedIndividual(1,1) = i(1); % first function x
evaluatedIndividual(1,2) = 1+ i(2) - i(1)^2; % second function 1 + y - x^2

