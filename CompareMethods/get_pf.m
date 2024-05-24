% Code from PlatEMO
function R = get_pf(problem, N)
    switch upper(problem)
        case "ZDT1"
            R(:,1) = linspace(0,1,N)';
            R(:,2) = 1 - R(:,1).^0.5;
        case "ZDT2"
            R(:,1) = linspace(0,1,N)';
            R(:,2) = 1 - R(:,1).^2;
        case "ZDT3"
            R(:,1) = linspace(0,1,N)';
            R(:,2) = 1 - R(:,1).^0.5 - R(:,1).*sin(10*pi*R(:,1));
            R(NDSort(R,1)>1,:) = nan;
        case "ZDT4"
            R(:,1) = linspace(0,1,N)';
            R(:,2) = 1 - R(:,1).^0.5;
        case "ZDT6"
            minf1  = 0.280775;
            R(:,1) = linspace(minf1,1,N)';
            R(:,2) = 1 - R(:,1).^2;
        otherwise
            disp("No matches found.")
            return;
    end
end
