% when neighbour is inf summation result in inf
function [fit_array]=crowding_distance(fit_array)
    global MOO_Method; 
    DistanceIndex=12;
    RankIndex=11;
    if(MOO_Method=='SPEA2')
        DistanceIndex=16;
        RankIndex=15;
    end
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
      
      %obj1 (index1)
      front=[front (1:size(front, 1))'];
      sortedFront=[sortrows(front,1)];
      
      sortedFront(1,DistanceIndex)=inf;
      sortedFront(end,DistanceIndex)=inf;
      for m=2:l-1
        sortedFront(m,DistanceIndex)= (sortedFront(m,DistanceIndex)+ (sortedFront(m+1,1)-sortedFront(m-1,1))/(max(fit_array(:,1))-min(fit_array(:,1))));
      end 
      
      sortedFront=[sortrows(sortedFront,size(sortedFront,2))];
      front=sortedFront(:,1:end-1);

      %obj2 (index10)
      front=[front (1:size(front, 1))'];
      sortedFront=[sortrows(front,10)];
      
      sortedFront(1,DistanceIndex)=inf;
      sortedFront(end,DistanceIndex)=inf;
      for m=2:l-1
        sortedFront(m,DistanceIndex)= (sortedFront(m,DistanceIndex)+ (sortedFront(m+1,10)-sortedFront(m-1,10))/(max(fit_array(:,10))-min(fit_array(:,10))));
      end 
      
      sortedFront=[sortrows(sortedFront,size(sortedFront,2))];
      front=sortedFront(:,1:end-1);
        
      fit_array(w:w+l-1,DistanceIndex)=front(:,DistanceIndex);
      w=w+l;
    end

end  
   
