function [plane, num_inliers, num_outliers] = ls_fitplane(data, ths, max_size)
n = length(ths);
points = [data ones(n,1)]';
if n > max_size
    samples = datasample(data, max_size);
else
    samples = data;
end
plane = fitplane(samples');
plane = plane';
res = abs((plane*points)./norm(plane(1:3)));
num_inliers = sum(res<ths);
num_outliers = n - num_inliers;
end