function [matPool] = Selection_Generic_NSGA(fit_array)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

matPool = crowded_tournament(fit_array,2);


function [matPool] = crowded_tournament(fit_array,k)
    
    global gas;
    matPool = zeros(gas.n_individuals,1);
    for i=1:gas.n_individuals
        matPool(i) = getCrowdedTournamentWinner(fit_array, k);
    end
end
function [winner] = getCrowdedTournamentWinner(fit_array, k)
	global gas; % genetic algorithm settings
    DistanceIndex=gas.n_ObjectiveFunctions+3;%index
    RankIndex=gas.n_ObjectiveFunctions+2;%index
    Index=gas.n_ObjectiveFunctions+1;%index
    distance = 0;
    bestRank = 0;
    winner = 0;
    for j=1:k
        index = ceil((gas.n_individuals)*rand);
        if j==1
            bestRank = fit_array(index,RankIndex);
            winner = fit_array(index,Index);
            distance = fit_array(index,DistanceIndex);
        else
            if bestRank > fit_array(index,RankIndex)
                bestRank = fit_array(index,RankIndex);
                winner = fit_array(index,Index);
            else
                if distance < fit_array(index,DistanceIndex)
                    bestRank = fit_array(index,RankIndex);
                    winner = fit_array(index,Index);
                    distance = fit_array(index,DistanceIndex);
                end
            end

        end
    end
end

end