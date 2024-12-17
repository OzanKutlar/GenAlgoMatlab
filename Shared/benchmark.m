function resultArr = benchmark(individual)
    global op;
    op.currentFE = op.currentFE + height(individual);
    
    switch upper(op.name)
        case "ZDT1"
            resultArr = zdt1(individual);
        case "ZDT2"
            resultArr = zdt2(individual);
        case "ZDT3"
            resultArr = zdt3(individual);
        case "ZDT4"
            resultArr = zdt4(individual);
        case "ZDT6"
            resultArr = zdt6(individual);
        case "KUR"
            resultArr = kur(individual);
        case "VIENNET"
            resultArr = Viennet(individual);
        case "DF1"
            resultArr = df1(individual, op.currentGen);
        case "DTLZ1"
            resultArr = dtlz1(individual);
        case "DTLZ2"
            resultArr = dtlz2(individual);
        case "DTLZ3"
            resultArr = dtlz3(individual);
        case "DTLZ4"
            resultArr = dtlz4(individual);
        case "DF3"
            resultArr = df3(individual, op.currentGen);
        otherwise
            error("No matches found for problem name: %s", op.name);
    end
end


function arr2 = zdt1(pop)
    g = g1(pop);
    f1 = pop(:, 1);
    f2 = g .* (1 - sqrt(f1 ./ g));
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

% DTLZ problems from PlatEMO
function arr2 = dtlz1(arr)
    global op;

    g      = 100*(op.numberOfDecisionVar-op.numberOfObjectives+1+sum((arr(:,op.numberOfObjectives:end)-0.5).^2-cos(20.*pi.*(arr(:,op.numberOfObjectives:end)-0.5)),2));
    arr2 = 0.5*repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(arr,1),1),arr(:,1:op.numberOfObjectives-1)],2)).*[ones(size(arr,1),1),1-arr(:,op.numberOfObjectives-1:-1:1)];
end

function arr2 = dtlz2(arr)
    global op;

    g      = sum((arr(:,op.numberOfObjectives:end)-0.5).^2,2);
    arr2 = repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(g,1),1),cos(arr(:,1:op.numberOfObjectives-1)*pi/2)],2)).*[ones(size(g,1),1),sin(arr(:,op.numberOfObjectives-1:-1:1)*pi/2)];
end

function arr2 = dtlz3(arr)
    global op;

    g      = 100*(op.numberOfDecisionVar-op.numberOfObjectives+1+sum((arr(:,op.numberOfObjectives:end)-0.5).^2-cos(20.*pi.*(arr(:,op.numberOfObjectives:end)-0.5)),2));
    arr2 = repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(arr,1),1),cos(arr(:,1:op.numberOfObjectives-1)*pi/2)],2)).*[ones(size(arr,1),1),sin(arr(:,op.numberOfObjectives-1:-1:1)*pi/2)];
end

function arr2 = dtlz4(arr)
    global op;

    arr(:,1:op.numberOfObjectives-1) = arr(:,1:op.numberOfObjectives-1).^100;
    g      = sum((arr(:,op.numberOfObjectives:end)-0.5).^2,2);
    arr2 = repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(g,1),1),cos(arr(:,1:op.numberOfObjectives-1)*pi/2)],2)).*[ones(size(g,1),1),sin(arr(:,op.numberOfObjectives-1:-1:1)*pi/2)];
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

function result = g5(arr)
    result = sum(power(arr - 0.5, 2));
end

function k = k_value()
    global op;
    k = op.numberOfDecisionVar - op.numberOfObjectives + 1;
end
