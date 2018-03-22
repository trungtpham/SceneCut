function RGB = imoverlay(X,map,varargin)
%IMOVERLAY Create Label Matrix MAP based Image Overlay with specified Properties.
%   RGB = IMOVERLAY(X,MAP) generates an output image RGB by overlaying a
%   label matrix MAP onto the input image X with default parameter values.
%
%   RGB = IMOVERLAY(X,MAP,PARAM1,VAL1,PARAM2,VAL2,___) overlays a label
%   matrix MAP onto the input image X, specifying parameters and
%   corresponding values that control various aspects of the output image
%   RGB.
%
%   Class Support
%   -------------
%   The input image X and label matrix MAP can be uint8, uint16, or double.
%   The label matrix MAP must contain finite nonnegative integers.
%   The output RGB is an M-by-N-by-3 array of class uint8.
%
%   PROPERTIES can be a comma-separated list of strings
%     'ColorMap'   -  colormap   (default 'jet')
%     'FaceAlpha'  -  MAP transparency  (range [0,1], default 1 denotes opacity)
%                     if equals to -1, the following five properties will be ignored
%     'ZeroColor'  -  background color  (uint8/double, default black)
%     'ZeroAlpha'  -  background transparency (range [0,1], default 1 denotes opacity)
%     'EdgeColor'  -  edge color (uint8/double, default white)
%     'EdgeAlpha'  -  edge transparency (range [0,1], default 1 denotes opacity)
%     'EdgeWidth'  -  edge width (default 1)
%
%   Example 1
%   ---------
%   RGB = imoverlay(X,map);
%
%   Example 2
%   ---------
%   RGB = imoverlay(X,map,'colormap',cmap,'facealpha',0.5,'zerocolor',[255 0 0],'zeroalpha',0.3,'edgewidth',5,'edgecolor',[1 1 0],'edgealpha',0.7);
%
%   Example 3
%   ---------
%   RGB = imoverlay(X,map,'facealpha',-1,'colormap','jet');
%
%
%   Reference ('FaceAlpha' equals to -1):
%   --------------------------------------------
%   http://www.vision.caltech.edu/~harel/share/gbvs.php
%
%
%   25/12/2015, ver 1.00
%   26/12/2015, ver 1.01, bug fix for custom ColorMap
%
%   Jing Lou (Â¥¾º), http://www.loujing.com
%

narginchk(2, inf);

% X
assert(ismatrix(X) || ndims(X)==3, 'X should be a grayscale or an RGB image.');
if ismatrix(X)
	X = repmat(X, [1 1 3]);
end

% MAP
assert(ismatrix(map), 'MAP should be a two-dimensional matrix.');
if size(map,1)~=size(X,1) || size(map,2)~=size(X,2)
	map = imresize(map, [size(X,1),size(X,2)], 'bicubic');
end

% check parameters
paramPairs = varargin;
assert(rem(length(paramPairs),2)==0, 'need param-value pairs');
for k = 1:2:length(paramPairs)
	validateattributes(paramPairs{k},{'char'},{'nonempty'});
	% convert to lowercase
	paramPairs(k) = lower(paramPairs(k));
end

% colormap
numregion = double(max(map(:)))+1;
ind_colormap = find(cellfun(@(s) strcmp('colormap',s), paramPairs), 1);
if isempty(ind_colormap)
	cmap = feval('jet',numregion);
else
	if ischar(paramPairs{ind_colormap+1})
		cmap = feval(paramPairs{ind_colormap+1},numregion);
	else
		cmap = mat2gray(paramPairs{ind_colormap+1});
	end
end

% MAP transparency
ind_facealpha = find(cellfun(@(s) strcmp('facealpha',s), paramPairs), 1);
if isempty(ind_facealpha)
	facealpha = 1;
else
	facealpha = paramPairs{ind_facealpha+1};
	assert((facealpha>=0 && facealpha<=1) || facealpha==-1, 'FACEALPHA should be in [0,1], or equals to -1');
end

%----------------------------------------------------------------------
% if 'FaceAlpha' equals to -1, properties 'ZeroColor/ZeroAlpha/EdgeColor/EdgeAlpha/EdgeWidth' will be ignored
if facealpha == -1
	
	% Reference: http://www.vision.caltech.edu/~harel/share/gbvs.php
	X = im2double(X);
	map = im2double(map);
	map = double(map)/max(map(:));
	RGB = 0.8*(1-repmat(map.^0.8,[1 1 3])).*double(X)/max(double(X(:))) + ...
		repmat(map.^0.8,[1 1 3]).* shiftdim(reshape(interp2(1:3,1:size(cmap,1),cmap,1:3,...
		1+(size(cmap,1)-1)*reshape(map, [numel(map) 1]))',[3 size(map)]),1);
	RGB = im2uint8(real(RGB));
	
else  % otherwise, i.e. 'FaceAlpha' in range [0,1])
	
	%----------------------------------------------------------------------
	% background color
	ind_zerocolor = find(cellfun(@(s) strcmp('zerocolor',s), paramPairs), 1);
	if isempty(ind_zerocolor)
		zerocolor = [0 0 0];
	else
		zerocolor = mat2gray(paramPairs{ind_zerocolor+1});
	end
	
	% background transparency
	ind_zeroalpha = find(cellfun(@(s) strcmp('zeroalpha',s), paramPairs), 1);
	if isempty(ind_zeroalpha)
		zeroalpha = 1;
	else
		zeroalpha = paramPairs{ind_zeroalpha+1};
		assert(zeroalpha>=0 && zeroalpha<=1, 'ZEROALPHA should be in [0,1]');
	end
	
	% edge color
	ind_edgecolor = find(cellfun(@(s) strcmp('edgecolor',s), paramPairs), 1);
	if isempty(ind_edgecolor)
		edgecolor = [1 1 1];
	else
		edgecolor = mat2gray(paramPairs{ind_edgecolor+1});
	end
	
	% edge transparency
	ind_edgealpha = find(cellfun(@(s) strcmp('edgealpha',s), paramPairs), 1);
	if isempty(ind_edgealpha)
		edgealpha = 1;
	else
		edgealpha = paramPairs{ind_edgealpha+1};
		assert(edgealpha>=0 && edgealpha<=1, 'EDGEALPHA should be in [0,1]');
	end
	
	% edge width
	ind_edgewidth = find(cellfun(@(s) strcmp('edgewidth',s), paramPairs), 1);
	if isempty(ind_edgewidth)
		edgewidth = 1;
	else
		edgewidth = paramPairs{ind_edgewidth+1};
	end
	
	%----------------------------------------------------------------------
	X = im2double(X);
	
	% edge
	edgergb = zeros(size(X,1),size(X,2),3);
	if ~isempty(ind_edgecolor) || ~isempty(ind_edgealpha) || ~isempty(ind_edgewidth)
		edgebw = edge(map,'roberts',0);
		if edgewidth > 1
			edgebw = imdilate(edgebw,ones(edgewidth)) > imerode(edgebw,ones(edgewidth));
		end
		edgergb = setColor(edgergb,edgebw,edgecolor);
	else
		edgebw = false(size(map,1),size(map,2));
	end
	RGBedge = linComb(X,edgergb,edgebw,edgealpha);
	
	% foreground
	tmp = map~=0;
	facebw = tmp - (tmp & edgebw);
	facergb = im2double(label2rgb(map,cmap,[0 0 0]));
	RGBface = linComb(X,facergb,facebw,facealpha);
	
	% background
	tmp = true(size(map,1),size(map,2));
	zerobw = tmp - edgebw - facebw;
	zerorgb = zeros(size(X,1),size(X,2),3);
	zerorgb = setColor(zerorgb,zerobw,zerocolor);
	RGBzero = linComb(X,zerorgb,zerobw,zeroalpha);
	
	%----------------------------------------------------------------------
	RGB = RGBedge + RGBface + RGBzero;
	RGB = im2uint8(RGB);

end

end % imoverlay


%----------------------------------------------------------------------
function I = setColor(I,mask,color)
% set pixels of I in MASK locations to specified COLOR
tmp = reshape(I,[],size(I,3));
tmp(logical(mask(:)),:) = repmat(color,sum(mask(:)),1);
I = reshape(tmp,size(I));
end % setColor


%----------------------------------------------------------------------
function I = linComb(I1,I2,mask,alpha)
% linear combination of images I1 and I2 in MASK locations with transparency ALPHA
I = zeros(size(I1,1),size(I1,2),3);
[row,col] = find(mask~=0);
for k = 1:length(row)
	r = row(k);
	c = col(k);
	I(r,c,1) = I1(r,c,1)*(1-alpha) + I2(r,c,1)*alpha;
	I(r,c,2) = I1(r,c,2)*(1-alpha) + I2(r,c,2)*alpha;
	I(r,c,3) = I1(r,c,3)*(1-alpha) + I2(r,c,3)*alpha;
end
end % linComb
