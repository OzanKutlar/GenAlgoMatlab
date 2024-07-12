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

disp("average igd for algorithm 1: " + mean(ranks1(:, 1)));
disp("average igd for algorithm 2: " + mean(ranks2(:, 1)));

[p, h] = ranksum(ranks1, ranks2);

disp("p-value: " + p);

if h
    disp("rank differences are significant");
else
    disp("rank differences are not significant");
end

save("results.mat", "ranks1", "ranks2", "p", "h")

font_size = 17;
% Experiment 1
data1(:, 1) = ranks1;
data1(:, 2) = ranks2;
data_names1 = ["NSBBBC", "NSGA-II"];

fig = figure(); 
boxplot(data1,data_names1)
%title('Experiment 1 (Tracking on Wall)');
%xlabel('Device');
ylabel('IGD');
fontsize(fig, font_size, "points");
%exportgraphics(gcf,'exp1_tracking.pdf','ContentType','vector');