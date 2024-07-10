algorithm = input("algorithm: ", "s");
algorithm_path = split(algorithm, "\");
delete(strjoin(algorithm_path(1:end-1, 1), "\") + "\*.mat");

for i = 1:20
    run(algorithm);
end