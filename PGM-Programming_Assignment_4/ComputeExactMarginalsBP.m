%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code
M = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = CreateCliqueTree(F, E);
P = CliqueTreeCalibrate(P, isMax);
vars = unique([P.cliqueList.var], 'first');
a = length(vars);
b = length(P.cliqueList);
M = repmat(struct('var', [], 'card', [], 'val', []), a, 1);

for i = 1:a
	for j = 1:b
		if (ismember(vars(i), P.cliqueList(j).var))
			toBeDeleted = setdiff(P.cliqueList(j).var, vars(i));
			if (isMax)
				M(i) = FactorMaxMarginalization(P.cliqueList(j), toBeDeleted);
			else
				M(i) = FactorMarginalization(P.cliqueList(j), toBeDeleted);
				M(i).val = M(i).val / sum(M(i).val);
			endif
			break;
		endif
	end
end
end
