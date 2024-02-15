
%objfunc is function that includes all of your objective function
%that function takes 1 individual and return their fitness'

function [fitarray] = objfunc(individual)

global gas

fitarray=zeros(1,gas.n_ObjectiveFunctions);

fitarray(1,1) = individual(1,1);
fitarray(1,2) = 1 + individual(1,2) - individual(1,1)^2; 
end