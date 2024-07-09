filename = input("result.mat location: ", "s");
load(filename);
disp(igd(pareto.data, get_pf(pareto.name, pareto.N)));