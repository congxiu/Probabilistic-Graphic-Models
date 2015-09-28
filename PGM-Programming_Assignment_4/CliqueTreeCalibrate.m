%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isMax)
	for i = 1:N
		P.cliqueList(i).val = log(P.cliqueList(i).val);
	end
endif


[i, j] = GetNextCliques(P, MESSAGES);
while ((i ~= 0) && (j~= 0))
	indices = P.edges(:, i);
	indices(j) = 0;
	product = P.cliqueList(i);
	toBeAdded = MESSAGES(indices == 1, i);
	if (isMax)
		for k = 1:length(toBeAdded)
			product = FactorSum(product, toBeAdded(k));
		end
	else
		for k = 1:length(toBeAdded)
			product = FactorProduct(product, toBeAdded(k));
		end
	endif
	vars = setdiff(P.cliqueList(i).var, P.cliqueList(j).var);
	if (isMax)
		MESSAGES(i, j) = FactorMaxMarginalization(product, vars);
	else
		MESSAGES(i, j) = FactorMarginalization(product, vars);
		MESSAGES(i, j).val = MESSAGES(i, j).val / sum(MESSAGES(i, j).val);
	endif

	[i, j] = GetNextCliques(P, MESSAGES);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:N
	product = P.cliqueList(i);
	toBeAdded = MESSAGES(P.edges(i, :) == 1, i);
	if (isMax)
		for k = 1:length(toBeAdded)
			product = FactorSum(product, toBeAdded(k));
		end
	else
		for k = 1:length(toBeAdded)
			product = FactorProduct(product, toBeAdded(k));
		end
	endif
	vars = setdiff(product.var, P.cliqueList(i).var);

	if (isMax)
		P.cliqueList(i) = FactorMaxMarginalization(product, vars);
	else
		P.cliqueList(i) = FactorMarginalization(product, vars);
	endif
end


return
