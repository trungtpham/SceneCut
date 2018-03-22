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

function [plane_model, color_model, outlier_ratio, plane_area] = ransac_fitplane(pointcloud, img, pixel_ids, noise_ths, iterations, subset_size)

color_data = img(pixel_ids,:);
pointcloud = pointcloud(pixel_ids, :);
noise_ths = noise_ths(pixel_ids);

% Compute color model
c_mean = mean(color_data);
c_std = std(color_data);
color_model = [c_mean, c_std];

% Remove invalid_depth pixels
z = pointcloud(:,3);
invalid_depth = z == 0;
pointcloud(invalid_depth,:) = [];
noise_ths(invalid_depth) = [];

s = size(pointcloud,1);
subset_size = min(subset_size, s);
homo_points = [pointcloud ones(s,1)]';
max_inliers = 0;
best_inliers  = [];
for i=1:iterations
    samples = datasample(pointcloud, subset_size);
    p = fitplane(samples');
    res = abs((p'*homo_points)./norm(p(1:3)));
    inliers = res < noise_ths;
    num_inliers = sum(inliers);
    if num_inliers > max_inliers
        max_inliers = num_inliers;
        best_inliers = inliers;
    end
end
if (iterations == 0)
    inliers = pointcloud;
else
    inliers = pointcloud(best_inliers, :);
end

if size(inliers,1) < 3
    plane_model  = [];
    outlier_ratio = 0;
    return;
end

max_sample = 1000;
if length(inliers) > max_sample
    samples = datasample(inliers, max_sample);
else
    samples = inliers;
end
plane_model = fitplane(samples')';
res = abs((plane_model*homo_points)./norm(plane_model(1:3)));
num_inliers = sum(res<noise_ths);
num_outliers = s - num_inliers;
outlier_ratio = num_outliers/num_inliers;

range = max(inliers) - min(inliers);
range = sort(range, 'descend');
plane_area = range(1)*range(2);

end