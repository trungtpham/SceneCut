clear all
close all
install

cmap = color_map(10000);

for f=1:10
    
    fprintf('processing image %d \n', f);
    
    % Load data
    load(strcat('NYU_data/hierarchies/img_', num2str(f+5000), '.mat'));
    im = imread(strcat('NYU_data/images/img_', num2str(f+5000), '.png'));
    load(strcat('NYU_data/pointcloud/img_', num2str(f+5000), '.mat'));
    
    im_hsv = rgb2hsv(im);
    im_hsv = reshape(im_hsv, [size(im,1)*size(im,2) 3]);
    pc = reshape(pc, [size(pc,1)*size(pc,2) 3]);
    
    [seg] = scenecut_segmentation(im_hsv, pc, tree, b_feats);
    
    
    % Display segmentation result
    color_map = cmap;
    seg_color = imoverlay(im, seg, 'colormap',color_map, 'facealpha',0.7,'zerocolor',[0 0 0],'zeroalpha',0.4, 'edgewidth',2, 'edgealpha',0.7);
    
    seg_ids = unique(seg);
    for i=1:length(seg_ids)
        l  = seg_ids(i); 
        if l <= 100 
            M = seg == seg_ids(i);
            stats = regionprops(M, 'Centroid');
            centroids = cat(1, stats.Centroid);   
            seg_color = insertText(seg_color, centroids, 'Surface', 'FontSize',12, 'AnchorPoint', 'Center', 'TextColor', 'blue', 'BoxOpacity',0.0);
        end
    end
    
    figure(1);imshow(seg_color);
    drawnow;
end

