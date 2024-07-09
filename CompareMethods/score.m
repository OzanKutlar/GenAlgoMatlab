file1 = input("algorithm 1: ", "s");
file2 = input("algorithm 2: ", "s");

ranks1 = [];
ranks2 = [];

counter = 1;
while isfile(file1 + "\result" + counter + ".mat")
    load(file1 + "\result" + counter + ".mat");
    ranks1(end + 1, 1) = igd(pareto.data, get_pf(pareto.name, pareto.N));
    counter = counter + 1;
end

counter = 1;
while isfile(file2 + "\result" + counter + ".mat")
    load(file2 + "\result" + counter + ".mat");
    ranks2(end + 1, 1) = igd(pareto.data, get_pf(pareto.name, pareto.N));
    counter = counter + 1;
end

[p, h] = ranksum(ranks1, ranks2);

disp("p-value: " + p);

if h
    disp("rank differences are significant");
else
    disp("rank differences are not significant");
end

save("results.mat", "ranks1", "ranks2", "p", "h")
