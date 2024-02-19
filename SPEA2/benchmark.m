function resultArr = benchmark(individual)
    global op;
    switch upper(op.name)
        case "ZDT1"
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 2;
            op.bounds = [0,1];
            resultArr = zdt1(individual);
        case "ZDT2"
            resultArr = zdt2(individual);
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 2;
            op.bounds = [0,1];
        case "ZDT3"
            resultArr = zdt3(individual);
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 2;
            op.bounds = [0,1];
        case "ZDT4"
            resultArr = zdt4(individual);
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 2;
            op.bounds = [0,1];
        case "ZDT6"
            resultArr = zdt6(individual);
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 2;
            op.bounds = [0,1];
        case "KUR"
            resultArr = kur(individual);
            op.numberOfDecisionVar = 3;
            op.numberOfObjectives = 2;
            op.bounds = [-5,5];
        case "DTLZ1"
            op.bounds = [0, 1];
            op.numberOfDecisionVar = 6;
            op.numberOfObjectives = 3;
            resultArr = dtlz1(individual, op.numberOfObjectives);
        case "VIENNET"
            op.bounds = [-3, 3];
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 3;
            resultArr = Viennet(individual);
        otherwise
            disp("No matches found.")
            return;
    end
end

function arr2 = zdt1(arr)
    g = g1(arr);
    f1 = arr(1);
    f2 = g * (1 - sqrt(arr(1) / g));
    arr2 = [f1, f2];
end

function arr2 = zdt2(arr)
    g = g1(arr);
    f1 = arr(1);
    f2 = g * (1 - power(arr(1) / g, 2));
    arr2 = [f1, f2];
end

function arr2 = kur(x) 
    f1 = 0;
    f2 = power(abs(x(1)), 0.8) + 5 * sin(power(x(1), 3));
    for i = 1:length(x)-1
        f1 = f1 + (-10 * exp(-0.2 * sqrt(x(i) * x(i) + x(i+1) * x(i+1))));
        f2 = f2 + power(abs(x(i+1)), 0.8) + 5 * sin(power(x(i+1), 3));
    end
    arr2 = [f1, f2];
end

function resultArr = Viennet(x)
    f1 = 0.5 * (x(1)^2 + x(2)^2) + sin(x(1)^2 + x(2)^2);
    f2 = (((3*x(1) - 2*x(2) + 4).^2 ) / 8) + (((x(1) - x(2) + 1)^2)/27) + 15;
    f3 = (1 / (x(1)^2 + x(2)^2 + 1)) - 1.1 * exp(-(x(1)^2 +x(2)^2));
    resultArr = [f1, f2, f3];
end




function arr2 = dtlz1(arr, objectiveCount)
    k = (length(arr) - objectiveCount) + 1;
    g = g4(arr(length(arr) - k:length(arr)));
    arr2 = zeros(1, objectiveCount);
    arr2(1) = 0.5 * prod(arr(1:objectiveCount - 1)) * (1 + g);
    for i = 2:objectiveCount
        if i == objectiveCount
            product = 1;
        else
            product = prod(arr(1:objectiveCount - i));
        end
        arr2(i) = 0.5 * product * (1 - arr((objectiveCount - i) + 1)) * (1 + g);
    end
end

function result = g4(arr)
    summation = 0;
    for i = 1:length(arr)
        summation = summation + power(arr(i) - 0.5, 2) - cos(20 * pi * (arr(i) - 0.5));
    end
    result = 100 * (length(arr) + summation);
end

function arr2 = zdt3(arr)
    g = g1(arr);
    f1 = arr(1);
    f2 = g * (1 - sqrt(arr(1) / g) - arr(1) / g * sin(10 * pi * arr(1)));
    arr2 = [f1, f2];
end

function arr2 = zdt4(arr)
    g = g2(arr);
    f1 = arr(1);
    f2 = g * (1 - sqrt(arr(1) / g));
    arr2 = [f1, f2];
end

function arr2 = zdt6(arr)
    g = g3(arr);
    f1 = 1 - exp(-4 * arr(1)) * power(sin(6 * pi * arr(1)), 6);
    f2 = g * (1 - power(f1 / g, 2));
    arr2 = [f1, f2];
end

function result = g1(arr)
    result = 1 + 9 * sum(arr(2:length(arr))) / (length(arr) - 1);
end

function result = g2(arr)
    summation = 0;
    for i = 2:length(arr)
        summation = summation + power(arr(i), 2) - 10 * cos(4 * pi * arr(i));
    end
    result = 1 + 10 * (length(arr) - 1) + summation;
end

function result = g3(arr)
    result = 1 + 9 * power(sum(arr(2:length(arr))) / (length(arr) - 1), 0.25);
end