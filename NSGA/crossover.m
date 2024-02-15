% Apply crossover operator on a pair of parents
%
% INPUT:
% 'p1' is the chromosome of the first parent [t+1 x n+4]
% 'p2' is the chromosome of the second parent [t+1 x n+4]
%
% OUTPUT:
% 'o1' is the chromosome of the first child [t+1 x n+4]
% 'o2' is the chromosome of the second child [t+1 x n+4]
function [o1, o2] = crossover(p1, p2)

global op;  % optimization problem
global gas; % genetic algorithm settings

if rand() <= gas.crossover_probability
    % do crossover
    switch gas.crossover_method
        case 'blxa'
            alpha = 0.5;

            o1 = blendCrossover(p1, p2, alpha);
            o2 = blendCrossover(p1, p2, alpha);


        case 'sbx'
            eta = 5;
            o1 = sbxCrossover(p1, p2, eta);
            o2 = sbxCrossover(p1, p2, eta);
        otherwise
            error('Unexpected Crossover Method.');
    end
else
    % don't do crossover, copy from parents
    o1 = p1;
    o2 = p2;

end

end

%--------------BLX-ALPHA CROSSOVER--------------

function [child] = blendCrossover(p1, p2, alpha)
global op;  % optimization problem
global gas; % genetic algorithm settings
child = zeros(1,2);
for i = 1:1:2
    gamma = (1+2*alpha)*rand - alpha;
    if(p1(1,i) < p2(1,i))
        child(1,i) = (1-gamma)*p1(1,i) + gamma*p2(1,i);
    else
        child(1,i) = (1-gamma)*p2(1,i) + gamma*p1(1,i);
    end
end
child(1,1) = min(max(child(1,1),0),1);
child(1,2) = min(max(child(1,2),0),3);

end





function [gene_c] = blendValues(gene_p1, gene_p2, alpha, bounds, isInteger)
if gene_p1 < gene_p2
    minGene = gene_p1;
    maxGene = gene_p2;
else
    minGene = gene_p2;
    maxGene = gene_p1;
end
u = rand();
gamma = (1+2*alpha)*u-alpha;
gene_c = (1-gamma)*minGene + gamma*maxGene;
gene_c = max(min(bounds(2),gene_c),bounds(1));

% if the gene is an integer number, transform it
if isInteger==true
    gene_c = nearest(gene_c);
end
end


%--------------SBX CROSSOVER--------------

function [o1, o2] = sbxCrossover(p1, p2, eta)
global op;  % optimization problem
global gas; % genetic algorithm settings
error('This Crossover Method is not implemented yet.');
end
