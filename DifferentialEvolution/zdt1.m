function f = zdt1(x)
    g = g1(x);
    f(1) = x(1);
    f(2) = g * (1 - sqrt(x(1) / g));
end

function result = g1(x)
    result = 1 + 9 * sum(x(2:length(x))) / (length(x) - 1);
end