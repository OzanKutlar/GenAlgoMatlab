% Code from PlatEMO
function R = get_pf(problem, N)
    global op;

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
            R      = R(NDSort(R,1)==1,:);
        case "ZDT4"
            R(:,1) = linspace(0,1,N)';
            R(:,2) = 1 - R(:,1).^0.5;
        case "ZDT6"
            minf1  = 0.280775;
            R(:,1) = linspace(minf1,1,N)';
            R(:,2) = 1 - R(:,1).^2;
        case "DTLZ1"
            R = UniformPoint(N,op.numberOfObjectives)/2;
        case "DTLZ2"
            R = UniformPoint(N,op.numberOfObjectives);
            R = R./repmat(sqrt(sum(R.^2,2)),1,op.numberOfObjectives);
        case "DTLZ3"
            R = UniformPoint(N,op.numberOfObjectives);
            R = R./repmat(sqrt(sum(R.^2,2)),1,op.numberOfObjectives);
        case "DTLZ4"
            R = UniformPoint(N,op.numberOfObjectives);
            R = R./repmat(sqrt(sum(R.^2,2)),1,op.numberOfObjectives);
        otherwise
            disp("No matches found.")
            return;
    end
end
