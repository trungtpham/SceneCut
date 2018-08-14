 function [tree, features] = ucm2tree(ucm)
 % This function computes a region hierarchy and node features from an UCM
 % Input: ucm (MxN) matrix representing a Ultrametric Contour Map
 
    hier = ucm2hier(ucm);
    start_ths = hier.start_ths';
    end_ths   = hier.end_ths';
    ms        = hier.ms_matrix;
    lps = hier.leaves_part;

    % Compute base features
    b_feats = compute_base_features(lps, ms, ucm);
    b_feats.start_ths = start_ths;
    b_feats.end_ths   = end_ths;
    b_feats.im_size   = size(lps);
        
    max_base_node = max(lps(:));
    tree = repmat(struct('parent',0, 'children', []), max_base_node, 1);
    P = num2cell(1:max_base_node);
    [tree.parent] = P{:};
    tree = cat(2, tree', hier.ms_struct);
    stats = regionprops(lps, 'PixelIdxList');
    masks = {stats.PixelIdxList};
    for j=max_base_node+1:length(tree)
        children = tree(j).children;
        masks{j} = cat(1, masks{children});
    end
    b_feats.masks = masks';
    
    features = b_feats;
end