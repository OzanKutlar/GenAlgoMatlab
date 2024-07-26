% Performs the mutation operator on a pair of parents
%
% INPUT: 
% 'chrom' is the chromosome of the individual to be mutated
%
% OUTPUT: 
% 'chrom' is the mutated chromosome [t+1 x n+4]
function [chrom] = mutation(chrom)
    
    global op;  % optimization problem
    global gas; % genetic algorithm settings
    
    if rand() <= gas.mutation_probability
        % do mutation
        switch gas.mutation_method
            case 'random'
                chrom = randomMutation();
            case 'modifiedRandom'
                chrom = modifiedRandomMutation(chrom);
            case 'polynomial'
                chrom = polynomialMutation(chrom);
            otherwise
                error('Unexpected Mutation Method.');
        end
    end

end

%--------------RANDOM MUTATION--------------

function [chrom] = randomMutation()
    chrom = generateRandomChromosome();
end

%--------------MODIFIED RANDOM MUTATION--------------

function [chrom] = modifiedRandomMutation(chrom)
    global op;  % optimization problem
    global gas; % genetic algorithm settings
   
end

%--------------POLYNOMIAL MUTATION--------------

function [chrom] = polynomialMutation(chrom)
    global op;  % optimization problem
    global gas; % genetic algorithm settings
    % error('This Mutation Method is not implemented yet.');
    
    eta_m = gas.eta_mutation;

    lower = op.bounds(1);
    upper = op.bounds(2);

    for i = 1:op.numberOfDecisionVar
        u = rand();

        if u <= 0.5
            L = (2*u)^(1/eta_m)-1;
            chrom(i) = chrom(i)+L*(chrom(i)-lower); 
        else
            R = 1-(2*(1-u))^(1/(1+eta_m));
            chrom(i) = chrom(i)+R*(upper-chrom(i)); 
        end
    end
    
    % Lower = op.bounds(1);
    % Upper = op.bounds(2);
    % Site  = rand() < gas.mutation_probability/width(chrom);
    % mu    = rand();
    % temp  = Site & mu<=0.5;
    % 
    % chrom = min(max(chrom, op.bounds(1)), op.bounds(2));
    % if(temp)
    %     chrom = chrom+(Upper-Lower).*((2.*mu+(1-2.*mu).*(1-(chrom-Lower)./(Upper-Lower)).^(eta_m+1)).^(1/(eta_m+1))-1);
    % end
    % temp = Site & mu>0.5;
    % if(temp)
    %     chrom = chrom+(Upper-Lower).*(1-(2.*(1-mu) + 2 .* (mu-0.5) .* (1-(Upper-chrom)./(Upper-Lower)).^(eta_m+1)).^(1/(eta_m+1)));
    % end

    % mu = rand(size(chrom));
    % chrom(mu < 0.5) = (2 * mu(mu < 0.5)).^(1 / (eta_c + 1)) - 1;
    % chrom(mu >= 0.5) = 1 - (2 * (1 - mu(mu >= 0.5))).^(1 / (eta_c + 1));

end
