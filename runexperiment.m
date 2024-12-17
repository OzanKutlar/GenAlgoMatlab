function runexperiment(data)
    algorithms = string(data.algo);
    funcs = string(data.func);
    popCounts = string(data.pop);
    maxFEs = string(data.FE);
    ComputerID = string(data.id);

    array = ["SPPSO/pso",
        "SPEA2/runIt",
        "SPDE/runIt",
        "SP-BBBC/runBBBC",
        "RP-SPEA/runIt",
        "RP-SPDE/runIt",
        "RP-SP-BBBC/runBBBC",
        "RP-NSDE/Template_nsga",
        "RP-NS-BBBC/runBBBC",
        "Rewritten-BBBC",
        "PSO/runSwarm",
        "NSPSO/NSPSO",
        "NSPS-III/pso",
        "NSGA-III/Template_nsga",
        "NSGA-II/Template_nsga",
        "NSDE/Template_nsde",
        "NSBBBC3/runBBBC",
        "NSBBBC/runBBBC"
        ];

    for i = 1:width(algorithms)
        folderName = algorithms(i);
        for j = 1:height(array)
            temp = split(array(j), "/");
            if(upper(folderName) == temp(1))
                eval(sprintf('cd %s', temp(1)));
                break;
            end
        end
        for ii = 1:width(funcs)
            func = funcs(ii);
            for iii = 1:width(popCounts)
                popCount = popCounts(iii);
                for iV = 1:width(maxFEs)
                    maxFE = maxFEs(iV);
                    eval(sprintf('%s("%s",%s,%s)', temp(2), func, maxFE, popCount));
                end
            end
        end
        cd ..
    end

end