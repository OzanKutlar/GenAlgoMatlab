function [evaluatedIndividual] = evaluateIndividual(i)
    % Rosenbrock
    global op;
    global bbbcs;
    temp = benchmark(i);
    bbbcs.currentFE = bbbcs.currentFE + 1;
    for j=1:op.numberOfObjectives
        evaluatedIndividual(j) = temp(j);
    end
end