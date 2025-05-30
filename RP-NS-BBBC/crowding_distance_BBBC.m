% when neighbour is inf summation result in inf
function [pop]=crowding_distance_BBBC(pop)
global bbbcs;
w=1;
sz=size(pop,1);
n=size(unique(pop(:,bbbcs.rankIndex)),1);
pop(:,bbbcs.crowdingDistIndex)=0;

for i=1:n
    front=[];
    for j=1:sz
        if pop(j,bbbcs.rankIndex)==i
            front=[front; pop(j,:)];
        end
    end
    l=size(front,1);

    if l==1
        front(end,bbbcs.crowdingDistIndex)=1000;
    end
    for k=1:bbbcs.numberOfObjectives
        front=[front (1:size(front, 1))'];
        sortedFront=[sortrows(front,bbbcs.n_variables+1:bbbcs.n_variables + 1 + k)];

        sortedFront(1,bbbcs.crowdingDistIndex)=1000;
        sortedFront(end,bbbcs.crowdingDistIndex)=1000;
        for m=2:l-1
            sortedFront(m,bbbcs.crowdingDistIndex)= sortedFront(m,bbbcs.crowdingDistIndex)+ ((abs(sortedFront(m+1,bbbcs.n_variables+1:bbbcs.n_variables + 1 + k)-sortedFront(m-1,bbbcs.n_variables+1:bbbcs.n_variables + 1 + k)))/(max(pop(:,bbbcs.n_variables+1:bbbcs.n_variables + 1 + k))-min(pop(:,bbbcs.n_variables+1:bbbcs.n_variables + 1 + k))));
        end

        sortedFront=[sortrows(sortedFront,size(sortedFront,2))];
        front=sortedFront(:,1:end-1);
    end

    pop(w:w+l-1,bbbcs.crowdingDistIndex)=front(:,bbbcs.crowdingDistIndex);
    w=w+l;
end

end

