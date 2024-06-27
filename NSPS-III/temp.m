pareto = zeros(width(swarm), width(swarm(1).position));
for i = 1:width(swarm)
    pareto(i, :) = swarm(i).position;
end
