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


function [segmentation] = scenecut_segmentation(img, pointcloud, tree, features)

% Input: 
%   img: input HSV image
%   pointcloud: input point cloud
%   tree: segmentation hierarchical tree
%   features: contain features for each node (region) such as area,
%   boundary scores.
% Ouput:
%   segmentation: output segmentation where labels greater than 100 indicates object instances, 
%   otherwise plane instances. 

% Compute objectness scores
objectness_scores  = compute_objectness_scores(features);
% Compute geometric (plane) scores
geometric_scores   = compute_plane_fitting_scores(pointcloud, img, features);

% Combine semantic (object) and geometric scores
weights = [objectness_scores geometric_scores];
% Run scenecut using dynamic programming
[cut, node_labels] = tree_cut_dynamic_programming(tree, weights);

% Making segmentation map
selected_nodes = find(cut==1);
im_size = features.im_size;
segmentation = zeros(im_size);
for i=1:length(selected_nodes)
    label = node_labels(selected_nodes(i));
    idx = features.masks{selected_nodes(i)};
    if label == 1
        segmentation(idx) = 100 + i;
    else
        segmentation(idx) = label;   
    end
end

end