function [cMass] = bigCrunchPhase(pop, setting)
    switch setting
        case 'eq1'
            cMass = bigCrunchPhase_eq1(pop);
        case 'eq2'
            cMass = bigCrunchPhase_eq2(pop);
    end
end

function [cMass] = bigCrunchPhase_eq1(pop)
    global bbbcs;

    pareto = getPareto(pop);
    positions = getPositions(pop);

    
    if pop(bbbcs.n_cmass, bbbcs.rankIndex) == 1
        if pop(bbbcs.n_cmass + 1, bbbcs.rankIndex) == 1
            checkSize=height(pop(pop(:,bbbcs.rankIndex) == 1, :));
            [normalizedSwarm, reference_directions] = doNormalize(pareto(1:checkSize, :));
            assosiations = assosiate(normalizedSwarm, reference_directions, positions(1:checkSize, :));
            addedElites = 0;
            cMass = zeros(bbbcs.n_cmass, bbbcs.n_variables);
            while true
                for i = 1:width(assosiations)
                    if(addedElites == bbbcs.n_cmass)
                        break
                    end
                    if(assosiations(i).count - 1 <= 0)
                        continue;
                    end

                    shortest = assosiations(i).pop(1);
                    shortestIndex = 1;
                    for j = 2:assosiations(i).count - 1
                        if(assosiations(i).pop(j).dist <= shortest.dist)
                            if(assosiations(i).pop(j).dist == shortest.dist && rand() >= 0.5) 
                                continue;
                            end
                            shortest = assosiations(i).pop(j);
                            shortestIndex = j;
                        end
                    end

                    addedElites = addedElites + 1;
                    cMass(addedElites, :) = shortest.position(:);
                    assosiations(i).count = assosiations(i).count - 1;
                    assosiations(i).pop(shortestIndex) = [];
                end

                if(addedElites == bbbcs.n_cmass)
                    break
                end
            end

        else
            cMass = pop(1:bbbcs.n_cmass, 1:bbbcs.n_variables);
        end
    else
        target = pop(bbbcs.n_cmass, bbbcs.rankIndex);
        if pop(bbbcs.n_cmass + 1, bbbcs.rankIndex) == target
            targetIndex = 0;
            for i = bbbcs.n_cmass:-1:1
                if(pop(i, bbbcs.rankIndex) == target - 1)
                    targetIndex = i + 1;
                    break;
                end
            end
            endIndex = 0;
            for i = targetIndex:height(pop)
                if(pop(i, bbbcs.rankIndex) == target + 1)
                    endIndex = i - 1;
                    break;
                end
            end
            
            [normalizedSwarm, reference_directions] = doNormalize(pareto(1:targetIndex - 1, :));
            assosiationsNonDom = assosiate(normalizedSwarm, reference_directions, positions(1:targetIndex - 1, :));
            [normalizedSwarm, reference_directions] = doNormalize(pareto(targetIndex:endIndex, :));
            assosiationsLastLayer = assosiate(normalizedSwarm, reference_directions, positions(targetIndex:endIndex, :));
    
            addedElites = targetIndex - 1;
            cMass = zeros(bbbcs.n_cmass, bbbcs.n_variables);
            cMass(1:targetIndex - 1, :) = positions(1:targetIndex - 1, :);
    
            while true
                shortestIndex = 1;
                for i = 2:width(assosiationsNonDom)
                    if(assosiationsNonDom(i).count <= 1)
                        continue;
                    end
                    if(assosiationsNonDom(i).count <= assosiationsNonDom(shortestIndex).count)
                        if(assosiationsNonDom(i).count == assosiationsNonDom(shortestIndex).count && rand() >= 0.5)
                            continue;
                        end
                        shortestIndex = i;
                    end
                end

                if(assosiationsLastLayer(shortestIndex).count <= 1)
                    assosiationsNonDom(shortestIndex).count = Inf;
                    continue;
                end
                shortestParticleIndex = 1;
                shortest = assosiationsLastLayer(shortestIndex).pop(1);
                for i = 2:assosiationsLastLayer(shortestIndex).count - 1
                    if(assosiationsLastLayer(shortestIndex).pop(i).dist <= shortest.dist)
                        if(assosiationsLastLayer(shortestIndex).pop(i).dist == shortest.dist && rand() >= 0.5)
                            continue;
                        end
                        shortest = assosiationsLastLayer(shortestIndex).pop(i);
                        shortestParticleIndex = i;
                    end
                end

                addedElites = addedElites + 1;
                cMass(addedElites, :) = shortest.position;
                assosiationsLastLayer(shortestIndex).pop(shortestParticleIndex) = [];
                assosiationsLastLayer(shortestIndex).count = assosiationsLastLayer(shortestIndex).count - 1;
                assosiationsNonDom(shortestIndex).count = assosiationsNonDom(shortestIndex).count + 1;

                if(addedElites == bbbcs.n_cmass)
                    break;
                end
            end
        else
            cMass = pop(1:bbbcs.n_cmass, 1:bbbcs.n_variables);
        end
    end
end

function positions = getPareto(pop)
    global bbbcs;
    positions = pop(:, bbbcs.n_variables + 1:bbbcs.n_variables + bbbcs.numberOfObjectives);
end

function positions = getPositions(pop)
    global bbbcs;
    positions = pop(:, 1:bbbcs.n_variables);
end

function [cMass] = bigCrunchPhase_eq2(pop)
    global bbbcs;
    sumFit = 0.0;
    sumFit_x1 = 0.0;
    sumFit_x2 = 0.0;
    for i=1:1:bbbcs.N
        sumFit = sumFit + pop(i,4);

        sumFit_x1 = sumFit_x1 + pop(i,4) * pop(i,1);
        sumFit_x2 = sumFit_x2 + pop(i,4) * pop(i,2);
    end
    cMass(1,1) = sumFit_x1 / sumFit;
    cMass(1,2) = sumFit_x2 / sumFit;
end    
