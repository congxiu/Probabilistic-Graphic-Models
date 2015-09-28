%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);
indices = 1:length(C.factorList);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[vars indexA] = unique([C.factorList.var], "first");
cards = [C.factorList.card](indexA);
factorAssignment = cell(N, 1);
for i = 1:N
	toBeDeleted = [];
	currVar = C.nodes{i};
	P.cliqueList(i).var = currVar;
	for j = 1:length(indices)
		if (isempty(setdiff(C.factorList(indices(j)).var, currVar)))
			factorAssignment{i}(end + 1) = indices(j);
			toBeDeleted(end + 1) = j;
		endif
	end
	indices(toBeDeleted) = [];
end

for i = 1:N
	product = struct('var', C.nodes{i}, 'card', cards(C.nodes{i}), 'val', []);
	product.val = ones(1, prod(product.card));
	for j = 1:length(factorAssignment{i})
		product =...
		 FactorProduct(product, C.factorList(factorAssignment{i}(j)));
	end
	P.cliqueList(i) = StandardizeFactors(product);
end

P.edges = C.edges;
end

