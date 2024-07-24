function [evaluatedIndividual] = evaluateIndividual(i)
    % Rosenbrock
    global op;
    temp = benchmark(i);
    for j=1:op.numberOfObjectives
        evaluatedIndividual(j) = temp(j);
    end
end