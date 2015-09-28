function factors = ChooseTopSimilarityFactors (allFactors, F)
% This function chooses the similarity factors with the highest similarity
% out of all the possibilities.
%
% Input:
%   allFactors: An array of all the similarity factors.
%   F: The number of factors to select.
%
% Output:
%   factors: The F factors out of allFactors for which the similarity score
%     is highest.
%
% Hint: Recall that the similarity score for two images will be in every
%   factor table entry (for those two images' factor) where they are
%   assigned the same character value.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

m = length(allFactors);
% If there are fewer than F factors total, just return all of them.
if (m <= F)
    factors = allFactors;
    return;
end

values = zeros(m, 1);
% Your code here:
for i = 1:m
    values(i) = allFactors(i).val(1);
end

[~,I] = sort(values, "descend");

factors = allFactors(I(1:F));
end

