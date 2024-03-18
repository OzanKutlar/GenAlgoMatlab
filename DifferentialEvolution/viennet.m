function resultArr = viennet(x)
    f1 = 0.5 * (x(1)^2 + x(2)^2) + sin(x(1)^2 + x(2)^2);
    f2 = (((3*x(1) - 2*x(2) + 4).^2 ) / 8) + (((x(1) - x(2) + 1)^2)/27) + 15;
    f3 = (1 / (x(1)^2 + x(2)^2 + 1)) - 1.1 * exp(-(x(1)^2 +x(2)^2));
    resultArr = [f1, f2, f3];
end