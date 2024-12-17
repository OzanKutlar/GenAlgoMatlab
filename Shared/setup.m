function setup(opName)
    global op;
    op.name = upper(opName);
    
    switch op.name
        case "ZDT1"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "ZDT2"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "ZDT3"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "ZDT4"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "ZDT6"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "KUR"
            op.numberOfDecisionVar = 3;
            op.numberOfObjectives = 2;
            op.bounds = repmat([-5, 5], op.numberOfDecisionVar, 1);
        case "VIENNET"
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 3;
            op.bounds = repmat([-3, 3], op.numberOfDecisionVar, 1);
        case "DTLZ1"
            op.numberOfDecisionVar = 5;
            op.numberOfObjectives = 3;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "DTLZ2"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 3;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "DTLZ3"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 3;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        case "DTLZ4"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 3;
            op.bounds = repmat([0, 1], op.numberOfDecisionVar, 1);
        otherwise
            error("Unsupported problem name: %s", op.name);
    end
    
    op.currentFE = 0;
end
