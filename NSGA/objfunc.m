
%objfunc is function that includes all of your objective function
%that function takes 1 individual and return their fitness'

function [fitarray] = objfunc(individual)

global gas;

fitarray=zeros(1,gas.n_ObjectiveFunctions);

fitarray(1, :) = benchmark(individual);
end