% ------------------------------------------------------------------------ 
%  Copyright (C)
%  The Australian Center of Robotic Vision. The University of Adelaide
% 
%  Trung Pham <trung.pham@adelaide.edu.au>
%  March 2018
% ------------------------------------------------------------------------ 
% This file is part of the SceneCut method presented in:
%   T. T. Pham, TT Do, N. Snderhauf, I. Reid 
%   SceneCut: Joint Geometric and Object Segmentation for Indoor Scenes 
%   IEEE International Conference on Robotics and Automation, 2018
% Please consider citing the paper if you use this code.


function [cut, node_labels, energy] = tree_cut_dynamic_programming(Tree, weights)

% Find optimal tree cut using Dynamic Programming
% Input:
% T: is an input tree, implemented using a struct with two fields: parent and
% children
% weights: is a weight vector, one weight for each node
% Output:
% cut: a binary vector where 1 means node is selected, 0 otherwise
% energy: maximum cut energy

num_nodes = length(Tree);
root = Tree(end).parent;

[max_weights, node_labels] = max(weights, [], 2);

if (length(weights)~= num_nodes)
    error('Weights vector must contain exactly %d values\n', num_nodes);
end

% Recurively computing maximum weight for each node based on its children
bottom_up_weights = zeros(num_nodes, 1);
bottom_up_weights = dynamic_programming_bottomup(Tree, root, max_weights, bottom_up_weights);

% Recurively tracking back to find the optimal cut
backward_assignment = zeros(num_nodes,1);
cut = dynamic_programming_topdown(Tree, root, max_weights, bottom_up_weights, backward_assignment);
energy = sum(max_weights(cut==1));

end

%% Recurively computing maximum weight for each node
function bottom_up_weights = dynamic_programming_bottomup(Tree, root, weights, bottom_up_weights)
    
    children = Tree(root).children;
    children(children == 0) = [];
    
    if (isempty(children))
        bottom_up_weights(root) = weights(root);
        return;
    end
    
    max_weight = 0;
    for c=1:length(children)
        child = children(c);
        bottom_up_weights = dynamic_programming_bottomup(Tree, child, weights, bottom_up_weights);
        max_weight = max_weight + max(bottom_up_weights(child), weights(child));
    end
    bottom_up_weights(root) = max_weight;
end


%% Recurively tracking back to find the optimal cut
function [labels] = dynamic_programming_topdown(T, root, weights, bottom_up_weights, labels)
if weights(root) >= bottom_up_weights(root)
    labels(root) = 1;
else
    children = T(root).children;
    children(children == 0) = [];
    for c=1:length(children)
        child = children(c);
        labels = dynamic_programming_topdown(T, child, weights, bottom_up_weights, labels);
    end
end
end



