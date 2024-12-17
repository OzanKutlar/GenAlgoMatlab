function setup(opName)
    global op;
    op.name = upper(opName);
    
    switch op.name
        case "ZDT1"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        case "ZDT2"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        case "ZDT3"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        case "ZDT4"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        case "ZDT6"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        case "KUR"
            op.numberOfDecisionVar = 3;
            op.numberOfObjectives = 2;
            op.bounds = [-5, 5];
        case "VIENNET"
            op.numberOfDecisionVar = 2;
            op.numberOfObjectives = 3;
            op.bounds = [-3, 3];
        case "DF1"
            op.changeFreq = 1 / 10;
            op.changeSeverity = 1 / 10;
            op.currentGen = 0;
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        case "DTLZ1"
            op.numberOfDecisionVar = 5;
            op.numberOfObjectives = 3;
            op.bounds = [0, 1];
        case "DTLZ2"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 3;
            op.bounds = [0, 1];
        case "DTLZ3"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 3;
            op.bounds = [0, 1];
        case "DTLZ4"
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 3;
            op.bounds = [0, 1];
        case "DF3"
            op.changeFreq = 1 / 10;
            op.changeSeverity = 1 / 50;
            op.currentGen = 0;
            op.numberOfDecisionVar = 10;
            op.numberOfObjectives = 2;
            op.bounds = [0, 1];
        otherwise
            error("Unsupported problem name: %s", op.name);
    end
    
    op.currentFE = 0;
end
