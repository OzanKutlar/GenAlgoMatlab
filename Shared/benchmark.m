function resultArr = benchmark(individual, setup)
    global op;
    if(nargin == 1) 
        setup = false; 
    end
    switch upper(op.name)
        case "ZDT1"
            if setup
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt1(individual);
        case "ZDT2"
            if setup
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt2(individual);
        case "ZDT3"
            if setup
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt3(individual);
        case "ZDT4"
            if setup
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = zdt4(individual);
        case "ZDT6"
            if setup
                op.numberOfDecisionVar = 10;
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
        case "DF1"
            if setup
                op.changeFreq = 1 / 10;
                op.changeSeverity = 1 / 10;
                op.currentGen = 0;
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = df1(individual, op.currentGen);
        case "DTLZ1"
            if setup
                op.numberOfDecisionVar = 5;
                op.numberOfObjectives = 5;
                op.bounds = [0,1];
                return;
            end
            resultArr = dtlz1(individual);
        case "DTLZ2"
            if setup
                op.numberOfDecisionVar = 3;
                op.numberOfObjectives = 3;
                op.bounds = [0,1];
                return;
            end
            resultArr = dtlz2(individual);
        case "DTLZ3"
            if setup
                op.numberOfDecisionVar = 3;
                op.numberOfObjectives = 3;
                op.bounds = [0,1];
                return;
            end
            resultArr = dtlz3(individual);
        case "DTLZ4"
            if setup
                op.numberOfDecisionVar = 3;
                op.numberOfObjectives = 3;
                op.bounds = [0,1];
                return;
            end
            resultArr = dtlz4(individual);
        case "DF3"
            if setup
                op.changeFreq = 1 / 10;
                op.changeSeverity = 1 / 50;
                op.currentGen = 0;
                op.numberOfDecisionVar = 10;
                op.numberOfObjectives = 2;
                op.bounds = [0,1];
                return;
            end
            resultArr = df3(individual, op.currentGen);
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

function arr2 = df1(arr, gen)
    global op;
    gen = max(gen + op.changeFreq - (51), 0);
    t = op.changeSeverity * floor(gen * op.changeFreq);

    G = 1 + sum( power(arr(2:length(arr)) - abs(sin(0.5*pi*t) ), 2)  );
    H = 0.75*sin(0.5*pi*t)+1.25;
    f1 = arr(1);
    f2 = G * (1 - power((arr(1)/G), H));
    arr2 = [f1, f2];
end

function arr2 = df3(arr, gen)
    global op;
    t = op.changeSeverity * (gen * op.changeFreq);
    f1 = arr(1);
    g_x = 1 + sum(arr(2:end) - sin(0.5*pi*t) - arr(1).^(1.5 + sin(0.5*pi*t)).^2);
    f2 = g_x * (1 - (arr(1)/g_x).^(1.5 + sin(0.5*pi*t)));
    arr2 = [f1, f2];
end

function arr2 = df12(arr, gen)
    global op;
    t = op.changeSeverity * (gen * op.changeFreq);
    f1 = arr(1);
    f2 = gdf1(arr, t);
    f2 = f2 * (1 - power((arr(1)/f2), 0.75*sin(0.5*pi) + 1.25));
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
