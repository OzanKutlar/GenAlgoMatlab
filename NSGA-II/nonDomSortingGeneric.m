function [fit_array] = nonDomSortingGeneric(fit_array)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global gas

index=gas.n_ObjectiveFunctions+1; %index



rankIndex=gas.n_ObjectiveFunctions+2; %rank index

temp_fit_array = fit_array;
rank = 1;
while ~isempty(temp_fit_array)
    P = [];
    for i = 1:height(temp_fit_array)
        counter = 0;
        for j = 1:height(temp_fit_array)
            if i == j
                continue
            end
           % if j dominates i break     temp_fit_array(j,k) < temp_fit_array(i,k)
            
                if(dominates(temp_fit_array(j,1:gas.n_ObjectiveFunctions),temp_fit_array(i,1:gas.n_ObjectiveFunctions),gas.isMin,gas.strongDominance))
                    break;
                    
                else
                    counter = counter + 1;
                end
            
           if counter == height(temp_fit_array) - 1
               P = [P,temp_fit_array(i,index)];
           end
        end
    end



    if size(temp_fit_array,1) == 1
        P = temp_fit_array(1,index);
    end
    for i = 1:length(P)
        fit_array(fit_array(:,index) == P(i),rankIndex) = rank;
    end
    for i = 1:length(P)
        temp_fit_array(temp_fit_array(:,index) == P(i),:) = [];
    end
    rank = rank + 1;  
end
fit_array = sortrows(fit_array,rankIndex);
end