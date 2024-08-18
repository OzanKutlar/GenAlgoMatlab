function [evaluatedIndividual] = evaluateIndividual(i)
    % Rosenbrock
    global op;
    temp = benchmark(i);
    for j=1:op.numberOfObjectives
        evaluatedIndividual(j) = temp(j);
    end
end

function [evaluatedIndividual] = evaluateIndividualAA(i)
    % Rosenbrock
   
    f1 = 0;
    f2 = power(abs(i(1)), 0.8) + 5 * sin(power(i(1), 3));
    for j = 1:length(i)-1
        f1 = f1 + (-10 * exp(-0.2 * sqrt(i(j) * i(j) + i(j+1) * i(j+1))));
        f2 = f2 + power(abs(i(j+1)), 0.8) + 5 * sin(power(i(j+1), 3));
    end
    evaluatedIndividual = [f1, f2];
end

    