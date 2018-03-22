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

function scores  = compute_plane_fitting_scores(pointcloud, img, features)

num_pixels = size(img, 1);
areas = features.areas;
masks = features.masks;
num_nodes = length(areas);

% Memory keeper
plane_models = zeros(100,4);
plane_areas  = zeros(100,1);
color_models = zeros(100,6);

Z = pointcloud(:,3)';
noise_ths   = 0.02 + 0.005*(Z-0.4).^2;
points_homo = [pointcloud, ones(num_pixels, 1)]';
count = 0;
for n=1:num_nodes
    
    % Ignore too big or too small regions
    if (areas(n) < 10000 || areas(n) > 100000)
        continue;
    end
    
    idx  = masks{n};
    num_iterations = 1;
    subset_size = 500;
    [p_model, c_model, outlier_ratio, plane_area] = ransac_fitplane(pointcloud, img, idx, noise_ths, num_iterations, subset_size);
    
    if isempty(p_model) || outlier_ratio > 0.3 || plane_area < 0.5
        continue;
    end
    
    plane_models(count+1,:) = p_model;
    color_models(count+1,:) = c_model;
    plane_areas(count+1) = plane_area;
    count = count + 1;
    
end
num_planes = count;
% No plane found
if num_planes == 0
    scores = [];
    return;
end

plane_models = plane_models(1:count,:);
plane_areas = plane_areas(1:count,:);
color_models = color_models(1:count, :);

z = sqrt(sum(plane_models(:, 1:3).^2,2));
z = repmat(z, 1, 4);
plane_models = plane_models./z;
plane_models = plane_models.*sign(plane_models(:,4));
plane_scores = normalize_var(plane_areas, 0.25, 1);


p2p_distances = plane_models*points_homo;
p2p_distances = (p2p_distances).^2./repmat(noise_ths.^2, num_planes, 1);
distance_fit  = exp(-p2p_distances);


% Uncomment these the below lines if one want to use normals.
%normal_ths  = 0.50 + 0.005*(Z-0.4).^2;
%normals = pcnormals(pointCloud(pointcloud))';
%normal_fit = (abs(plane_models(:,1:3)*normals) - 1).^2./repmat(normal_ths.^2, num_planes, 1);
%normal_fit = exp(-normal_fit);

color_means = color_models(:,1:3);
color_stds = 2.*color_models(:, 4:6);

color_fit_h = pdist2(color_means(:,1), img(:,1), 'squaredeuclidean')./repmat(2.*(color_stds(:,1).^2), 1, num_pixels);
color_fit_s = pdist2(color_means(:,2), img(:,2), 'squaredeuclidean')./repmat(2.*(color_stds(:,2).^2), 1, num_pixels);
color_fit_v = pdist2(color_means(:,3), img(:,3), 'squaredeuclidean')./repmat(2.*(color_stds(:,3).^2), 1, num_pixels);
color_fit = exp(-(color_fit_h + color_fit_s + color_fit_v));

invalid_depth_idx = Z == 0;
%plane_goodness_fit = (distance_fit.*normal_fit.*color_fit);
plane_goodness_fit = (distance_fit.*color_fit);
plane_goodness_fit = max(plane_goodness_fit, 1e-10);
plane_goodness_fit(:,invalid_depth_idx) = 0.5;

plane_goodness_fit = plane_goodness_fit.*repmat(plane_scores, 1, num_pixels);
log_plane_goodness_fit = log(plane_goodness_fit);

scores = zeros(num_nodes, num_planes);
for n=1:num_nodes    
    idx = masks{n};
    if length(idx) < 5000
        S = log(1e-3).*areas(n)^0.95;
    else
        gof = log_plane_goodness_fit(:,idx);
        S = mean(gof, 2).*areas(n)^0.95;
    end
    scores(n,:) = S;
end
end