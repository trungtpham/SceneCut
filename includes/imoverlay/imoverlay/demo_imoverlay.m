% demo for imoverlay
% IMOVERLAY Create Label Matrix MAP based Image Overlay with specified Properties.
%
%   MATLAB source code is available at https://github.com/jinglou/ImageProcessingToolbox
%                                   or https://www.mathworks.com/matlabcentral/fileexchange/54629-imoverlay
%
%
%   26/12/2015, ver 1.01
%
%   Jing Lou (Â¥¾º), http://www.loujing.com
%

clc; clear; close all;

%% 'FaceAlpha' in range [0,1]

X = imread('X1.jpg');
map = imread('map1.bmp');
% for the purpose of displaying MAP
map1 = im2uint8(mat2gray(map));
map1 = repmat(map1, [1 1 3]);
figure,imshow([X, map1]),title('FaceAlpha in [0,1]       (left: X, right: map)');

% Example 1
RGB = imoverlay(X,map);
figure,imshow(RGB),title('Example 1');

% Example 2
RGB = imoverlay(X,map,'colormap',jet(4),'facealpha',0.5);
figure,imshow(RGB),title('Example 2');

% Example 3 - custom colormap
cmap = [29   152  254;
		190  0    0;
		20   164  8];
RGB = imoverlay(X,map,'colormap',cmap,'zerocolor',[0 1 1],'zeroalpha',0.2);
figure,imshow(RGB),title('Example 3');

% Example 4 - uint8 color
RGB = imoverlay(X,map,'edgewidth',5,'edgecolor',[255 0 0],'edgealpha',0.6);
figure,imshow(RGB),title('Example 4');

% Example 5 - all properties
cmap = [0.1133  0.5977  0.9961; 
		0.7461  0       0;
		0.0781  0.6445  0.0313];
RGB = imoverlay(X,map,'colormap',cmap,'facealpha',0.5,'zerocolor',[255 0 0],'zeroalpha',0.3,'edgewidth',5,'edgecolor',[1 1 0],'edgealpha',0.7);
figure,imshow(RGB),title('Example 5');
out = [X, im2uint8(repmat(mat2gray(map),[1 1 3])), RGB];

% Example 6 - different image size & support other class
load X2.mat;
X = im2double(X);	% or im2uint16(X)
RGB = imoverlay(X,X2,'colormap','jet','facealpha',0.1,'edgecolor',[0 0 1],'edgealpha',0.5);
figure,imshow(RGB),title('Example 6');



%% 'FaceAlpha' equals to -1

X = imread('X3.bmp');
map = imread('map3.bmp');
% for the purpose of displaying MAP
map1 = imresize(map,[size(X,1),size(X,2)],'bicubic');
map1 = repmat(map1,[1 1 3]);
figure,imshow([X, map1]),title('FaceAlpha equals to -1       (left: X, right: map)');

% Example 7 - RGB color image
RGB = imoverlay(X,map,'facealpha',-1,'colormap','jet');
figure, imshow(RGB),title('Example 7');
out = [X, repmat(imresize(map,[size(X,1),size(X,2)],'bicubic'),[1 1 3]),RGB];

% Example 8 - grayscale image with custom colormap
Xgray = rgb2gray(X);
cmap = [0.1133  0.5977  0.9961; 
		0.7461  0       0;
		0.0781  0.6445  0.0313];
RGB = imoverlay(Xgray,map,'facealpha',-1,'colormap',cmap);
figure,imshow(RGB),title('Example 8');
