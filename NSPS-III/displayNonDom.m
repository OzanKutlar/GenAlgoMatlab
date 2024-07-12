i = 1;
hold on;
while true
    layersize = 0;
    for ii = i:width(nonDomLayers)
        if(isempty(nonDomLayers(ii).paretoPosition))
            break;
        end
        layersize = layersize + 1;
    end
    if(layersize == 0) 
        break;
    end
    currentLayer = zeros(layersize, width(nonDomLayers(1).paretoPosition));
    for iii = i:i+(layersize - 1)
        currentLayer((iii - i) + 1, :) = nonDomLayers(iii).paretoPosition;
    end
    scatter(currentLayer(:, 1), currentLayer(:, 2), 'filled');
    i = ii + 1;
end
hold off