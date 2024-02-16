% Initialize a random individual/chromosome
%
% INPUT: none
%
% OUTPUT: 
% 'chrom' is the random chromosome 
function [chrom] =  generateRandomChromosome()
    global op;  % optimization problem
    chrom = zeros(1,op.numberOfDecisionVar);
    chrom(1,:) = rand(1, op.numberOfDecisionVar);
end

