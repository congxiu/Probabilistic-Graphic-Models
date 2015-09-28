% CLUSTERGRAPHCALIBRATE Loopy belief propagation for cluster graph calibration.
%   P = CLUSTERGRAPHCALIBRATE(P, useSmart) calibrates a given cluster graph, G,
%   and set of of factors, F. The function returns the final potentials for
%   each cluster. 
%   The cluster graph data structure has the following fields:
%   - .clusterList: a list of the cluster beliefs in this graph. These entries
%                   have the following subfields:
%     - .var:  indices of variables in the specified cluster
%     - .card: cardinality of variables in the specified cluster
%     - .val:  the cluster's beliefs about these variables
%   - .edges: A cluster adjacency matrix where edges(i,j)=1 implies clusters i
%             and j share an edge.
%  
%   UseSmart is an indicator variable that tells us whether to use the Naive or Smart
%   implementation of GetNextClusters for our message ordering
%
%   See also FACTORPRODUCT, FACTORMARGINALIZATION
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function [P MESSAGES] = ClusterGraphCalibrate(P,useSmartMP)

if(~exist('useSmartMP','var'))
  useSmartMP = 0;
end

N = length(P.clusterList);

MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
[edgeFromIndx, edgeToIndx] = find(P.edges ~= 0);

for m = 1:length(edgeFromIndx),
    i = edgeFromIndx(m);
    j = edgeToIndx(m);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %
    %
    %
    % Set the initial message values
    % MESSAGES(i,j) should be set to the initial value for the
    % message from cluster i to cluster j
    %
    % The matlab/octave functions 'intersect' and 'find' may
    % be useful here (for making your code faster)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    from = P.clusterList(i);
    to = P.clusterList(j);
    vars = intersect(from.var, to.var);
    [~, idx] = ismember(vars, from.var);
    cards = from.card(idx);
    MESSAGES(i, j) = ...
    struct('var', vars, 'card', cards, 'val', ones(1, prod(cards)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;


i19j3 = [];
i15j40 = [];
i17j2 = [];


% perform loopy belief propagation
tic;
iteration = 0;

lastMESSAGES = MESSAGES;

while (1),
    iteration = iteration + 1;
    [i, j] = GetNextClusters(P, MESSAGES,lastMESSAGES, iteration, useSmartMP); 
    prevMessage = MESSAGES(i,j);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    % We have already selected a message to pass, \delta_ij.
    % Compute the message from clique i to clique j and put it
    % in MESSAGES(i,j)
    % Finally, normalize the message to prevent overflow
    %
    % The function 'setdiff' may be useful to help you
    % obtain some speedup in this function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    factors = P.clusterList(i);
    toReceive = find(P.edges(:, i));
    toReceive = toReceive(toReceive~=j);
    for k = 1:length(toReceive)
        factors = FactorProduct(factors, MESSAGES(toReceive(k), i));
    end
    toDelete = setdiff(P.clusterList(i).var, P.clusterList(j).var);
    factors = FactorMarginalization(factors, toDelete);
    factors.val = factors.val / sum(factors.val);
    MESSAGES(i, j) = factors;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(useSmartMP==1)
      lastMESSAGES(i,j)=prevMessage;
    end
    
    % Check for convergence every m iterations
    if mod(iteration, length(edgeFromIndx)) == 0
        if (CheckConvergence(MESSAGES, lastMESSAGES))
            break;
        end
        disp(['LBP Messages Passed: ', int2str(iteration), '...']);
        if(useSmartMP~=1)
          lastMESSAGES=MESSAGES;
        end
    end
    
    if (i == 19 && j == 3)
        i19j3(end + 1) = MessageDelta(prevMessage, MESSAGES(19, 3));
    endif

    if (i == 15 && j == 40)
        i15j40(end + 1) = MessageDelta(prevMessage, MESSAGES(15, 40));
    endif

    if (i == 17 && j == 2)
        i17j2(end + 1) = MessageDelta(prevMessage, MESSAGES(17, 2));    
    endif
end;
toc;
disp(['Total number of messages passed: ', num2str(iteration)]);


% Compute final potentials and place them in P
for m = 1:length(edgeFromIndx),
    j = edgeFromIndx(m);
    i = edgeToIndx(m);
    P.clusterList(i) = FactorProduct(P.clusterList(i), MESSAGES(j, i));
end

subplot(1,3,1);
plot(i19j3);
subplot(1,3,2);
plot(i15j40, 'r');
subplot(1,3,3);
plot(i17j2, 'g');
xlabel('#ofIterations');
ylabel('residual');
% Get the max difference between the marginal entries of 2 messages -------
function delta = MessageDelta(Mes1, Mes2)
delta = max(abs(Mes1.val - Mes2.val));
return;