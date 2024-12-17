function resultArr = benchmark(pop)
    global op;
    op.currentFE = op.currentFE + height(pop);
    
    switch upper(op.name)
        case "ZDT1"
            resultArr = zdt1(pop);
        case "ZDT2"
            resultArr = zdt2(pop);
        case "ZDT3"
            resultArr = zdt3(pop);
        case "ZDT4"
            resultArr = zdt4(pop);
        case "ZDT6"
            resultArr = zdt6(pop);
        case "KUR"
            resultArr = kur(pop);
        case "VIENNET"
            resultArr = Viennet(pop);
        case "DF1"
            resultArr = df1(pop, op.currentGen);
        case "DTLZ1"
            resultArr = dtlz1(pop);
        case "DTLZ2"
            resultArr = dtlz2(pop);
        case "DTLZ3"
            resultArr = dtlz3(pop);
        case "DTLZ4"
            resultArr = dtlz4(pop);
        case "DF3"
            resultArr = df3(pop, op.currentGen);
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


function arr2 = zdt2(pop)
    g = g1(pop);
    f1 = pop(:, 1);
    f2 = g .* (1 - (f1 ./ g).^2);
    arr2 = [f1, f2];
end

function arr2 = kur(pop)
    shifted_pop = pop(:, 2:end);
    shifted_pop = [shifted_pop, zeros(size(pop, 1), 1)];
    f1_terms = -10 * exp(-0.2 * sqrt(pop.^2 + shifted_pop.^2));
    f1 = sum(f1_terms(:, 1:end-1), 2); % Remove the column we created for calculation.
    
    % Compute f2
    f2 = sum(abs(pop).^0.8 + 5 .* sin(pop.^3), 2);
    
    arr2 = [f1, f2];
end


function resultArr = Viennet(X)
    x1 = X(:, 1);
    x2 = X(:, 2);

    f1 = 0.5 * (x1.^2 + x2.^2) + sin(x1.^2 + x2.^2);
    f2 = (((3 * x1 - 2 * x2 + 4).^2) / 8) + (((x1 - x2 + 1).^2) / 27) + 15;
    f3 = (1 ./ (x1.^2 + x2.^2 + 1)) - 1.1 * exp(-(x1.^2 + x2.^2));

    resultArr = [f1, f2, f3];
end


function arr2 = zdt3(arr)
    x1 = arr(:, 1);
    g = g1(arr);

    f1 = x1;
    f2 = g .* (1 - sqrt(x1 ./ g) - x1 ./ g .* sin(10 * pi * x1));

    arr2 = [f1, f2];
end


function arr2 = zdt4(arr)
    x1 = arr(:, 1);
    g = g2(arr);

    f1 = x1;
    f2 = g .* (1 - sqrt(x1 ./ g));

    arr2 = [f1, f2];
end


function arr2 = zdt6(arr)
    x1 = arr(:, 1);
    g = g3(arr);

    f1 = 1 - exp(-4 * x1) .* (sin(6 * pi * x1) .^ 6);
    f2 = g .* (1 - (f1 ./ g) .^ 2);

    arr2 = [f1, f2];
end


function arr2 = dtlz1(arr)
    global op;
    g = 100*(op.numberOfDecisionVar-op.numberOfObjectives+1+sum((arr(:,op.numberOfObjectives:end)-0.5).^2-cos(20.*pi.*(arr(:,op.numberOfObjectives:end)-0.5)),2));
    arr2 = 0.5*repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(arr,1),1),arr(:,1:op.numberOfObjectives-1)],2)).*[ones(size(arr,1),1),1-arr(:,op.numberOfObjectives-1:-1:1)];
end

function arr2 = dtlz2(arr)
    global op;
    g = sum((arr(:,op.numberOfObjectives:end)-0.5).^2,2);
    arr2 = repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(g,1),1),cos(arr(:,1:op.numberOfObjectives-1)*pi/2)],2)).*[ones(size(g,1),1),sin(arr(:,op.numberOfObjectives-1:-1:1)*pi/2)];
end

function arr2 = dtlz3(arr)
    global op;
    g = 100*(op.numberOfDecisionVar-op.numberOfObjectives+1+sum((arr(:,op.numberOfObjectives:end)-0.5).^2-cos(20.*pi.*(arr(:,op.numberOfObjectives:end)-0.5)),2));
    arr2 = repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(arr,1),1),cos(arr(:,1:op.numberOfObjectives-1)*pi/2)],2)).*[ones(size(arr,1),1),sin(arr(:,op.numberOfObjectives-1:-1:1)*pi/2)];
end

function arr2 = dtlz4(arr)
    global op;
    arr(:,1:op.numberOfObjectives-1) = arr(:,1:op.numberOfObjectives-1).^100;
    g = sum((arr(:,op.numberOfObjectives:end)-0.5).^2,2);
    arr2 = repmat(1+g,1,op.numberOfObjectives).*fliplr(cumprod([ones(size(g,1),1),cos(arr(:,1:op.numberOfObjectives-1)*pi/2)],2)).*[ones(size(g,1),1),sin(arr(:,op.numberOfObjectives-1:-1:1)*pi/2)];
end


function g = g1(arr)
    g = 1 + 9 * sum(arr(:, 2:end), 2) / (size(arr, 2) - 1);
end


function g = g2(arr)
    x_rest = arr(:, 2:end);
    g = 1 + 10 * (size(arr, 2) - 1) + sum(x_rest.^2 - 10 * cos(4 * pi * x_rest), 2);
end


function g = g3(arr)
    x_rest = arr(:, 2:end);
    g = 1 + 9 * (sum(x_rest, 2) / (size(arr, 2) - 1)).^0.25;
end
