function [x, y] = benchmark(str, z)
    switch upper(str)
        case "ZDT1"
            [x, y] = zdt1(z);
        case "ZDT2"
            [x, y] = zdt2(z);
        case "ZDT3"
            [x, y] = zdt3(z);
        case "ZDT4"
            [x, y] = zdt4(z);
        case "ZDT6"
            [x, y] = zdt6(z);
        case "KUR"
            [x, y] = kur(z);
        otherwise
            disp("No matches found.")
            return;
    end
end

function [f1, f2] = zdt1(arr)
    g = g1(arr);
    f1 = arr(1);
    f2 = g * (1 - sqrt(arr(1) / g));
end

function [f1, f2] = zdt2(arr)
    g = g1(arr);
    f1 = arr(1);
    f2 = g * (1 - power(arr(1) / g, 2));
end

function [f1, f2] = kur(x) 
    f1 = 0;
    f2 = power(abs(x(1)), 0.8) + 5 * sin(power(x(1), 3));
    for i = 1:length(x)-1
        f1 = f1 + (-10 * exp(-0.2 * sqrt(x(i) * x(i) + x(i+1) * x(i+1))));
        f2 = f2 + power(abs(x(i+1)), 0.8) + 5 * sin(power(x(i+1), 3));
    end
end

function [f1, f2] = zdt3(arr)
    g = g1(arr);
    f1 = arr(1);
    f2 = g * (1 - sqrt(arr(1) / g) - arr(1) / g * sin(10 * pi * arr(1)));
end

function [f1, f2] = zdt4(arr)
    g = g2(arr);
    f1 = arr(1);
    f2 = g * (1 - sqrt(arr(1) / g));
end

function [f1, f2] = zdt6(arr)
    g = g3(arr);
    f1 = 1 - exp(-4 * arr(1)) * power(sin(6 * pi * arr(1)), 6);
    f2 = g * (1 - power(f1 / g, 2));
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