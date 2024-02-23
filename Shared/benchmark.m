function resultArr = benchmark(individual, setup)
    global op;
    if(nargin == 1) 
        setup = false; 
    end
    switch upper(op.name)
        case "ZDT1"
            if setup
                op.numberOfDecisionVar = 2;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt1(individual);
        case "ZDT2"
            if setup
                op.numberOfDecisionVar = 2;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt2(individual);
        case "ZDT3"
            if setup
                op.numberOfDecisionVar = 2;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt3(individual);
        case "ZDT4"
            if setup
                op.numberOfDecisionVar = 2;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt4(individual);
        case "ZDT6"
            if setup
                op.numberOfDecisionVar = 2;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt6(individual);
        case "KUR"
            if setup
                op.numberOfDecisionVar = 3;
                op.numberOfObjectives = 2;
                op.bounds = [-5,5];
                return;
            end
            resultArr = kur(individual);
        case "VIENNET"
            if setup
                op.numberOfDecisionVar = 2;
                op.numberOfObjectives = 3;
                op.bounds = [-3,3];
                return;
            end
            resultArr = Viennet(individual);
        case "DTLZ1"
            if setup
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 3;
                op.bounds = [0,1];
                return;
            end
            resultArr = dtlz1(individual);
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

function arr2 = dtlz1(arr)
    global op;
    g = g4(arr(length(arr) - op.numberOfObjectives - 1:length(arr)), k_value());
    x = arr(1:op.numberOfObjectives - 1);
    arr2 = zeros(1, op.numberOfObjectives);

    for i = 1:op.numberOfObjectives
        f = 0.5 * (1 + g);
        f = f * prod(x(1:length(x) - (i - 1)));
        if i > 1
            f = f * (1 - x(length(x) - (i - 2)));
        end
        arr2(i) = f;
    end
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

function result = g4(arr, k)
    result = 100 * (k + sum(power(arr - 0.5, 2) - cos(20 * pi * (arr - 0.5))));
end

function result = g5(arr)
    result = sum(power(arr - 0.5, 2));
end

function k = k_value()
    global op;
    k = op.numberOfDecisionVar - op.numberOfObjectives + 1;
end
