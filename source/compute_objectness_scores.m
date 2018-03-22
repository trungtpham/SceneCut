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

function scores  = compute_objectness_scores(features)

start_ths = features.start_ths';
end_ths = features.end_ths';

sigma_i = 0.3;
sigma_o = 0.7;
prior_prob = 0.5;
region_scores = prior_prob.*exp(-abs(start_ths - 0).^2./sigma_i^2).*exp(-abs(end_ths - 1).^2./sigma_o^2);
Areas = features.areas;
too_big_small_regions_ids = Areas>150000 | Areas < 1000;
region_scores(too_big_small_regions_ids) = 0.001;
scores = log(region_scores).*(Areas.^0.95);

end