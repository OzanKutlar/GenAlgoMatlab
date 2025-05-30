function [fit_array] = crowding_distance_generic(fit_array)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

global gas
DistanceIndex=gas.n_ObjectiveFunctions+3;
RankIndex=gas.n_ObjectiveFunctions+2;
% obj1=1; %obj1 index
% obj2=2; %obj2 index


w=1;
sz=size(fit_array,1);
n=size(unique(fit_array(:,RankIndex)),1);
fit_array(:,DistanceIndex)=0;

for i=1:n
    front=[];
    for j=1:sz
        if fit_array(j,RankIndex)==i
            front=[front; fit_array(j,:)];
        end
    end
    l=size(front,1);

    if l==1
        front(end,DistanceIndex)=inf;
    end
    for k=1:gas.n_ObjectiveFunctions
        front=[front (1:size(front, 1))'];
        sortedFront=[sortrows(front,k)];

        sortedFront(1,DistanceIndex)=inf;
        sortedFront(end,DistanceIndex)=inf;
        for m=2:l-1
            sortedFront(m,DistanceIndex)= sortedFront(m,DistanceIndex)+ ((abs(sortedFront(m+1,k)-sortedFront(m-1,k)))/(max(fit_array(:,k))-min(fit_array(:,k))));
        end

        sortedFront=[sortrows(sortedFront,size(sortedFront,2))];
        front=sortedFront(:,1:end-1);
    end
    fit_array(w:w+l-1,DistanceIndex)=front(:,DistanceIndex);
    w=w+l;
end

end