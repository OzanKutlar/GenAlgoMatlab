% Initialize a random individual/chromosome
%
% INPUT: none
%
% OUTPUT: 
% 'chrom' is the random chromosome 
function [chrom] =  generateRandomChromosome()
    global op;  % optimization problem
    global gas;
    chrom = zeros(1,2);
    chrom(1,1) = rand;
    chrom(1,2) = rand * 3;
end

