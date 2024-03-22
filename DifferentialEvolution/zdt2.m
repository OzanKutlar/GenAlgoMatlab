function f = zdt2(x)
    g = g1(x);
    f(1) = x(1);
    f(2) = g * (1 - power(x(1) / g, 2));
end

function result = g1(x)
    result = 1 + 9 * sum(x(2:length(x))) / (length(x) - 1);
end