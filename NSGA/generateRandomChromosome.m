% Initialize a random individual/chromosome
%
% INPUT: 
% 'op' is the object describing the optimization problem 
%
% OUTPUT: 
% 'chrom' is the random chromosome [t+1 x n+4]
function [chrom] =  generateRandomChromosome()
    
    global op;  % optimization problem
    global gas;
%     chrom = zeros(1,gas.n_variables);
    chrom(1,:)= rand(1, op.numberOfDecisionVar);
end

