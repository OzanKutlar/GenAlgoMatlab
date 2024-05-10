clear
global parameters;
global op;
op.name = "ZDT1";
addpath('..\Shared');
whitebg("black");
benchmark(zeros(2,2), true);
op.bounds = repmat(op.bounds, op.numberOfDecisionVar, 1);

parameters.particleCount = 200; % Number of particles
parameters.personalConst = 2;
parameters.socialConst = 2;
parameters.iterationTime = 100; % Maximum number of 'iterations' to run the simulation
parameters.socialDistance = 1; % Distance at which particles are moved apart.

swarm.Pos = zeros(parameters.particleCount, op.numberOfDecisionVar);
swarm.Vel = zeros(parameters.particleCount, op.numberOfDecisionVar);
swarm.paretoPos = zeros(parameters.particleCount, op.numberOfObjectives);
%swarm.PersonalBestPos = zeros(parameters.particleCount,
%op.numberOfDecisionVar); % Unnecesary assignment.

% Initialize Swarm in random spots

for i = 1:op.numberOfDecisionVar
    swarm.Pos(:, i) = op.bounds(i, 1) + (op.bounds(i, 2)-op.bounds(i, 1)) .* rand(parameters.particleCount, 1);
    %swarm.Vel(:, i) = op.bounds(i, 1) + (op.bounds(i, 2)-op.bounds(i, 1)) .* rand(parameters.particleCount, 1);
end



swarm.PersonalBestPos = swarm.Pos;
swarm.PersonalBestVel = swarm.Vel;

% Do Initial Evaluation
for i = 1:parameters.particleCount
    swarm.paretoPos(i, :) = benchmark(swarm.Pos(i, :));
end

% Enter Main Loop
swarm.nonDom = zeros(parameters.particleCount + 1, 1);

for i = 1:parameters.iterationTime
    swarm.nonDom(end, 1) = 0;
    parameters.socialDistance = (1 - (i/parameters.iterationTime)) + (0.4 * (i/parameters.iterationTime));
    % Find non dominated examples.
    for ii = 1:parameters.particleCount
        dominated = false;
        particle1 = swarm.paretoPos(ii, :);
        for iii = 1:parameters.particleCount
            particle2 = swarm.paretoPos(iii, :);
            if all(particle2 <= particle1) && any(particle2 < particle1)
                dominated = true;
                break;
            end
        end
        if ~dominated
            swarm.nonDom(end) = swarm.nonDom(end) + 1;
            swarm.nonDom(swarm.nonDom(end)) = ii;
        end
    end

    % Calculate Niche Count
    swarm.nicheCounts = zeros(swarm.nonDom(end, 1), 2);
    for ii = 1:swarm.nonDom(end)
        iii = swarm.nonDom(ii);
        part1 = swarm.paretoPos(iii, :);
        rest = swarm.paretoPos;
        rest = abs(rest - part1);
        rest = rest .^ 2;
        rest = sqrt(sum(rest, 2));
        rest = parameters.socialDistance > rest;
        swarm.nicheCounts(ii, 1) = sum(rest) - 1;
        swarm.nicheCounts(ii, 2) = ii;
    end

    % Sort according to Niche Count
    swarm.nicheCounts = sortrows(swarm.nicheCounts);
    
    swarm.newPop.Pos = zeros(parameters.particleCount*2, op.numberOfDecisionVar);
    swarm.newPop.Vel = zeros(parameters.particleCount*2, op.numberOfDecisionVar);

    % Calculate new speed and Pos
    for ii = 1:parameters.particleCount
        globalBest = round(rand() * (swarm.nonDom(end) - 1)) + 1;
        swarm.Vel(ii, :) = swarm.Vel(ii, :) + parameters.personalConst*(swarm.PersonalBestPos(ii,:) - swarm.Pos(ii,:));
        swarm.Vel(ii, :) = swarm.Vel(ii, :) + parameters.socialConst*(swarm.Pos(swarm.nonDom(globalBest), :) - swarm.Pos(ii,:));
        swarm.Pos(ii, :) = swarm.Pos(ii, :) + swarm.Vel(ii, :);
        
        for iii = 1:op.numberOfDecisionVar
            swarm.Pos(ii, iii) = max(min(swarm.Pos(ii, iii), op.bounds(iii, 2)), op.bounds(iii, 1));
            swarm.Vel(ii, iii) = max(min(swarm.Vel(ii, iii), op.bounds(iii, 2)), op.bounds(iii, 1));
        end

        swarm.newPop.Pos(ii, :) = swarm.Pos(ii, :);
        swarm.newPop.Vel(ii, :) = swarm.Vel(ii, :);
        swarm.newPop.PersonalBestPos(ii, :) = swarm.PersonalBestPos(ii, :);
        swarm.newPop.PersonalBestVel(ii, :) = swarm.PersonalBestVel(ii, :);
        swarm.newPop.Pos(parameters.particleCount + ii, :) = swarm.PersonalBestPos(ii, :);
        swarm.newPop.Vel(parameters.particleCount + ii, :) = zeros(1, op.numberOfDecisionVar);
        swarm.newPop.PersonalBestPos(parameters.particleCount + ii, :) = swarm.PersonalBestPos(ii, :);
        swarm.newPop.PersonalBestVel(parameters.particleCount + ii, :) = swarm.PersonalBestVel(ii, :);
    end
    
    % Evaluate new speed and Pos
    for ii = 1:parameters.particleCount*2
        swarm.newPop.paretoPos(ii, :) = benchmark(swarm.newPop.Pos(ii, :));
    end


    

    swarm.newPop.nonDom = zeros((parameters.particleCount*2) + 1, 1);
    % Find next population non dominated
    for ii = 1:parameters.particleCount*2
        dominated = false;
        particle1 = swarm.newPop.paretoPos(ii, :);
        for iii = 1:parameters.particleCount*2
            particle2 = swarm.newPop.paretoPos(iii, :);
            if all(particle2 <= particle1) && any(particle2 < particle1)
                dominated = true;
                break;
            end
        end
        if ~dominated
            swarm.newPop.nonDom(end) = swarm.newPop.nonDom(end) + 1;
            swarm.newPop.nonDom(swarm.newPop.nonDom(end)) = ii;
        end
    end

    swarm.nextPop.Pos = zeros(parameters.particleCount, op.numberOfDecisionVar);
    swarm.nextPop.Vel = zeros(parameters.particleCount, op.numberOfDecisionVar);
    index = 0;
    for ii = 1:min((swarm.newPop.nonDom(end) + swarm.nonDom(end)), parameters.particleCount)
        randomIndex = round(rand() * (swarm.newPop.nonDom(end) + swarm.nonDom(end) - 1)) + 1;
        if (randomIndex > swarm.nonDom(end))
            randomIndex = randomIndex - swarm.nonDom(end);
            particle.Pos = swarm.newPop.Pos(swarm.newPop.nonDom(randomIndex), :);
            particle.PersonalBestPos = swarm.newPop.PersonalBestPos(swarm.newPop.nonDom(randomIndex), :);
            particle.PersonalBestVel = swarm.newPop.PersonalBestVel(swarm.newPop.nonDom(randomIndex), :);
            particle.Vel = swarm.newPop.Vel(swarm.newPop.nonDom(randomIndex), :);
			particle.Pareto = swarm.newPop.paretoPos(swarm.newPop.nonDom(randomIndex), :);
            swarm.newPop.nonDom(end) = swarm.newPop.nonDom(end) - 1;
        else
            particle.Pos = swarm.Pos(swarm.nonDom(randomIndex), :);
            particle.PersonalBestPos = swarm.PersonalBestPos(swarm.nonDom(randomIndex), :);
            particle.PersonalBestVel = swarm.PersonalBestVel(swarm.nonDom(randomIndex), :);
			particle.Pareto = swarm.paretoPos(swarm.nonDom(randomIndex), :);
            particle.Vel = swarm.Vel(swarm.nonDom(randomIndex), :);
            swarm.nonDom(end) = swarm.nonDom(end) - 1;
        end
        
        swarm.nextPop.Pos(ii, :) = particle.Pos(1, :);
        swarm.nextPop.Vel(ii, :) = particle.Vel(1, :);
		swarm.nextPop.paretoPos(ii, :) = particle.Pareto(1, :);
        swarm.nextPop.PersonalBestPos(ii, :) = particle.PersonalBestPos(1, :);
        swarm.nextPop.PersonalBestVel(ii, :) = particle.PersonalBestVel(1, :);
        index = ii;
    end

    if (index < parameters.particleCount)
        
        while(1)
            % Clear newPop Non Dom List
            removed = 0;
            for ii = 1:height(swarm.newPop.nonDom)
                if(swarm.newPop.nonDom(ii, 1) == 0)
                    break
                end
                swarm.newPop.Pos(swarm.newPop.nonDom(ii - removed, 1), :) = [];
                swarm.newPop.Vel(swarm.newPop.nonDom(ii - removed, 1), :) = [];
                swarm.newPop.paretoPos(swarm.newPop.nonDom(ii - removed, 1), :) = [];
                removed = removed + 1;
            end
    
            swarm.newPop.nonDom = zeros(parameters.particleCount + 1, 1);
            % Find next population non dominated
            for ii = 1:height(swarm.newPop.paretoPos)
                dominated = false;
                particle1 = swarm.newPop.paretoPos(ii, :);
                for iii = 1:height(swarm.newPop.paretoPos)
                    particle2 = swarm.newPop.paretoPos(iii, :);
                    if all(particle2 <= particle1) && any(particle2 < particle1)
                        dominated = true;
                        break;
                    end
                end
                if ~dominated
                    swarm.newPop.nonDom(end) = swarm.newPop.nonDom(end) + 1;
                    swarm.newPop.nonDom(swarm.newPop.nonDom(end)) = ii;
                end
            end
        
            for ii = 1:swarm.newPop.nonDom(end)
                index = index + 1;
                if(index > parameters.particleCount)
                    break;
                end
                particle.Pos = swarm.newPop.Pos(swarm.newPop.nonDom(ii), :);
                particle.Vel = swarm.newPop.Vel(swarm.newPop.nonDom(ii), :);
                particle.Pareto = swarm.newPop.paretoPos(swarm.newPop.nonDom(ii), :);
                swarm.newPop.nonDom(end) = swarm.newPop.nonDom(end) - 1;
                swarm.nextPop.Pos(index, :) = particle.Pos(1, :);
                swarm.nextPop.paretoPos(index, :) = particle.Pareto(1, :);
                swarm.nextPop.Vel(index, :) = particle.Vel(1, :);
                swarm.nextPop.PersonalBestPos(index, :) = swarm.newPop.PersonalBestPos(swarm.newPop.nonDom(ii), :);
                swarm.nextPop.PersonalBestVel(index, :) = swarm.newPop.PersonalBestVel(swarm.newPop.nonDom(ii), :);
            end
            if(index >= parameters.particleCount)
                break;
            end
        end
    
    end

    swarm.Pos(:, :) = swarm.nextPop.Pos(:, :);
    swarm.Vel(:, :) = swarm.nextPop.Vel(:, :);
    swarm.paretoPos(:, :) = swarm.nextPop.paretoPos(:, :);
    swarm.PersonalBestPos(:, :) = swarm.nextPop.PersonalBestPos(:, :);
    swarm.PersonalBestVel(:, :) = swarm.nextPop.PersonalBestVel(:, :);

    % Do Final benchmark for visuals
    swarm.Val = zeros(parameters.particleCount, op.numberOfObjectives);
    for ii = 1:parameters.particleCount
        swarm.Val(ii, :) = benchmark(swarm.Pos(ii, :));
    end

    if op.numberOfObjectives == 2
        %hold on
        % scatter(swarm.Pos(:, 1), swarm.Pos(:, 2), 'filled','red');
        scatter(swarm.Val(:, 1), swarm.Val(:, 2), 'filled','red');
        legend(strcat("Generation : ", num2str(i)))
        %scatter(swarm.nextPop.paretoPos(:, 1), swarm.nextPop.paretoPos(:, 2), 'filled','DisplayName',"Particle Swarm");
        %hold off
    end
    if op.numberOfObjectives == 3
        scatter3(swarm.nextPop.paretoPos(:, 1),swarm.nextPop.paretoPos(:, 2), swarm.nextPop.paretoPos(:, 3),'filled');
    end
    drawnow;
end

