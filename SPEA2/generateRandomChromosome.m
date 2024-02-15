% Initialize a random individual/chromosome
%
% INPUT: none
%
% OUTPUT: 
% 'chrom' is the random chromosome 
function [chrom] =  generateRandomChromosome()
    global op;  % optimization problem
    global gas;
    chrom = zeros(1,gas.numberOfDecisionVar);
    %chrom(1,1) = rand;
    %chrom(1,2) = rand * 3;
    chrom(1,1) = (rand*10)-5;
    chrom(1,2) = (rand*10)-5;
    chrom(1,3) = (rand*10)-5;
end

