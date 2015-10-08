% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeLinearExpectations( I )
  % Inputs: An influence diagram I with a single decision node and one or more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  % You may assume that there is a unique optimal decision.
  %
  % This is similar to OptimizeMEU except that we will have to account for
  % multiple utility factors.  We will do this by calculating the expected
  % utility factors and combining them, then optimizing with respect to that
  % combined expected utility factor.  
  MEU = [];
  OptimalDecisionRule = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  % A decision rule for D assigns, for each joint assignment to D's parents, 
  % probability 1 to the best option from the EUF for that joint assignment 
  % to D's parents, and 0 otherwise.  Note that when D has no parents, it is
  % a degenerate case we can handle separately for convenience.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  INew = I;

  for i = 1:length(I.UtilityFactors)
    INew.UtilityFactors = I.UtilityFactors(i);
    EUFs(i) = CalculateExpectedUtilityFactor(INew);
  end

  euf = EUFs(1);
  for i = 2:length(EUFs)
    euf = FactorSum(euf, EUFs(i));
  end

  D = I.DecisionFactors(1);
  OptimalDecisionRule = D;
  OptimalDecisionRule.val = zeros(1, length(OptimalDecisionRule.val));
  indices = 1:D.card(1):prod(D.card) + 1;
  MEU = 0;

  for i = 1:length(indices)-1
    [currU, k] = max(euf.val(indices(i):indices(i+1) - 1));
    OptimalDecisionRule.val(indices(i) + k - 1) = 1;
    MEU = MEU + currU;
  end


end
