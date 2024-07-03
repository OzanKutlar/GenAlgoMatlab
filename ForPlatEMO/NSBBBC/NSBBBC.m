classdef NSBBBC < ALGORITHM
% <multi> <real/integer/label/binary/permutation> <constrained/none>
% Nondominated sorting genetic algorithm II

%------------------------------- Reference --------------------------------
% K. Deb, A. Pratap, S. Agarwal, and T. Meyarivan, A fast and elitist
% multiobjective genetic algorithm: NSGA-II, IEEE Transactions on
% Evolutionary Computation, 2002, 6(2): 182-197.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Population = Problem.Initialization();
            [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Problem.N);

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

            bbbcs_pop = Population.decs;
            [FrontNo, ~] = NDSort(Population.objs,Population.cons,Problem.N);
            CrowdDis = CrowdingDistance(Population.objs,FrontNo);
            bbbcs_pop(:, Problem.D + 1) = FrontNo';
            bbbcs_pop(:, Problem.D + 2) = CrowdDis';

            counter = 1;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                if counter ~= 1
                    Offspring = bigBangPhase_1(cMass, counter);
                    Offspring = Problem.Evaluation(Offspring);
                    [Population,FrontNo,CrowdDis] = EnvironmentalSelection([Population,Offspring],Problem.N);
                    bbbcs_pop = Population.decs;
                    bbbcs_pop(:, Problem.D + 1) = FrontNo';
                    bbbcs_pop(:, Problem.D + 2) = CrowdDis';
                else
                    Offspring = Problem.Initialization();
                end

                cMass = bigCrunchPhase(bbbcs_pop, 'eq1');
                
                counter = counter + 1;
            end
        end
    end
end