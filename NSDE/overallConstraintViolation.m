function[pop] = overallConstraintViolation(pop)
pop(:,21) = 0;
for i=1:size(pop,1)
    for j=15:20

        if(max(pop(:,j)) - min(pop(:,j)) ~=0)
            pop(i,j) = (pop(i,j) - min(pop(:,j))) / (max(pop(:,j)) - min(pop(:,j)));
        end

        if pop(i,j)~=0
            pop(i,21)=pop(i,21)+pop(i,j);
        end
    end

end

end