classdef NSBBBC3 < ALGORITHM
    methods
        function main(Algorithm,Problem)
            %% Generate the reference points and random population
            [Z,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Population    = Problem.Initialization();
            Zmin          = min(Population(all(Population.cons<=0,2)).objs,[],1);

            %% BBBCS settings
            global bbbcs;
            bbbcs.n_cmass = floor(Problem.N / 10);
            bbbcs.k = floor(Problem.N / bbbcs.n_cmass);
            bbbcs.bounds = repmat([Problem.lower(1), Problem.upper(1)], Problem.D, 1);
            bbbcs.N = Problem.N;
            bbbcs.n_objectives = Problem.M;
            bbbcs.n_variables = Problem.D;
            bbbcs.rankIndex = bbbcs.n_variables + 1;
            bbbcs.crowdingDistIndex = bbbcs.n_variables + 2;
            cMass = zeros(1, bbbcs.n_variables);

            counter = 1;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                if counter ~= 1
                    Offspring = bigBangPhase_1(cMass, counter);
                    Offspring = Problem.Evaluation(Offspring);
                else
                    Offspring = Problem.Initialization();
                end

                bbbcs_pop = Population.decs;
                [FrontNo, ~] = NDSort(Population.objs,Population.cons,Problem.N);
                CrowdDis = CrowdingDistance(Population.objs,FrontNo);
                bbbcs_pop(:, Problem.D + 1) = FrontNo';
                bbbcs_pop(:, Problem.D + 2) = CrowdDis';
                cMass = bigCrunchPhase(bbbcs_pop, 'eq1');
                
                counter = counter + 1;
                Zmin       = min([Zmin;Offspring(all(Offspring.cons<=0,2)).objs],[],1);
                Population = EnvironmentalSelection([Population,Offspring],Problem.N,Z,Zmin);
            end
        end
    end
end