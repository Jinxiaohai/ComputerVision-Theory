function fig = coarse_pixels_draw(bgIm,fgIm)
% COARSE_PIXELS_DRAW displays foreground image on background binary image
% CMP Vision Algorithms http://visionbook.felk.cvut.cz 
% Vaclav Hlavac, 2007-06-27
% 
% This is an auxiliary function for displaying coarse binary images. 
% It serves as 
% a complement to imshow or other Matlab\/ image display 
% functions. The function displays two binary images at once, the foreground
% image is overlaid on top of the background image. The background 
% image pixels are 
% displayed in black (value zero) and white (value 1). The black color 
% means an empty pixel and a white color means a pixel belonging 
% to the object(s). 
% Empty pixels of the foreground image are not displayed. The pixels
% corresponding to objects in the foreground image are displayed 
% as red squares inside the background pixels. 
% The sizes of pixels are automatically adjusted to 
% the size of input image. The maximal sizes of the background 
% and foreground images are [32 x 32].
% 
% Usage: fig = coarse_pixels_draw(bgIm,fgIm)
% Inputs:
%   bgIm  [m x n]  Input binary image to be shown as the background.
%   fgIm  [m x n]  Input binary image to be shown as the foreground.
%     The size of the background image has to be <= the
%     size of the foreground image. The empty array [] means 
%     that there is no foreground image to be displayed.
% See also: image, imagesc, imshow.

maxAllowedImageSize = 32;
pixelGridColor = [0.45,0.72,0.89]; % color of lines dividing pixels
pixelMarkerShape = 's'; % square
pixelMarkerEdgeColor = 'r'; % red color
pixelMarkerFaceColor = 'r';

if ~islogical(bgIm), 
    error('Background image bgIm has to be logical.') 
end
sizeBgIm = size(bgIm);

if isempty(fgIm)
    % No foreground image provided. Only background image will be shown.
    sizeFgIm = sizeBgIm;
elseif ~islogical(fgIm),
    error('Foreground image fgIm has to be logical.')
else
    % Normal mode. There is foreground image to be displayed.
    sizeFgIm = size(fgIm);
end

if nnz(sizeBgIm < sizeFgIm)
    error('Size of the fgIm has to be <= than size of bgIm.')
end

maxImageSize = max(max(sizeBgIm,sizeFgIm));
if maxImageSize > maxAllowedImageSize
    error('Images to be displayed are too big. Max size is %d.', ...
        maxImageSize)
end

% Display the background image
fig = imshow(bgIm, 'InitialMagnification', 'fit');
hold on

% Get position and size of the displayed image for calculating relative
% width of the pixels border lines and size of squares for foreground image
% pixels.
currFig = gcf;
set(currFig,'Units','pixels');
positionFig = get(currFig,'Position');
widthFig = positionFig(3);
heightFig = positionFig(4);

% Adjust size of borderline and markers to the image size and 
% the number of pixels to be displayed.
maxFigureSize = max(max(widthFig,heightFig));
pixPerOneSquare = maxFigureSize/maxImageSize;
pixelGridWidth = round(0.05 * pixPerOneSquare);
pixelMarkerSize = round(0.28 * pixPerOneSquare); 

% Draw the grid in the image displaying pixel boundaries in color 
% pixelGridColor.

% Add one element because lines are at the left and right side of the
% pixel.
xRows=1:sizeBgIm(1)+1;
sizexRows = size(xRows,2);
yColumns = 1:sizeBgIm(2)+1;
sizeyColumns = size(yColumns,2);

% Calculate the max size in order to cope both with portrait and landscape
% rectangular images.

maxRectanDim = max(sizexRows,sizeyColumns); 

% Draw vertical grid lines. 
% Store points coordinates in the matrix of size 2xn.
xvec = zeros(2,maxRectanDim);
xvec(1,:) = 1:maxRectanDim;
xvec(2,:) = 1:maxRectanDim;
xvec(1,:) = xvec(1,:) - 0.5;
xvec(2,:) = xvec(2,:) - 0.5;
yvec = zeros(2,maxRectanDim);
yvec(1,:) = 0.5;
yvec(2,:) = sizexRows - 0.5;
line(xvec, yvec,'Color',pixelGridColor,'LineWidth',pixelGridWidth);

% Draw horizontal grid lines.
xvec = zeros(2,maxRectanDim);
xvec(1,:) = 0.5;
xvec(2,:) = sizeyColumns - 0.5;
yvec = zeros(2,maxRectanDim);
yvec(1,:) = 1:maxRectanDim;
yvec(2,:) = 1:maxRectanDim;
yvec(1,:) = yvec(1,:) - 0.5;
yvec(2,:) = yvec(2,:) - 0.5;
line(xvec, yvec,'Color',pixelGridColor,'LineWidth',pixelGridWidth);

% Draw the background image into the created figure as smaller squares
% inside the appropriate pixels.
if ~isempty(fgIm)
    % Draw foreground image only in the case it exists.
    [fgr,fgc] = find(fgIm); % Collect coordinates of non-zero pixels.

    % Draw symbols to the grid corresponding to the foreground binary image.
    plot(fgc, fgr, pixelMarkerShape,...
        'LineWidth',1,...
        'MarkerEdgeColor',pixelMarkerEdgeColor,...
        'MarkerFaceColor',pixelMarkerFaceColor,...
        'MarkerSize',pixelMarkerSize);
end

return; % end of coars_pixels_draw

