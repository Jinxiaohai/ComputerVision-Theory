function [compIm,imsize] = creDatMatFromIm(numOfIm,imFnmBeg,imFnmExt);
% CREDATMATFROMIM Create data matrix from images. (used for PCA calculation)
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Vaclav Hlavac, 2007
%
% Usage: [compIm,imsize] = creDatMatFromIm(numOfIm,imFnmBeg,imFnmExt)
% Inputs:
%   numOfIm  1x1  Number of images.
%   imFnmBeg      Core string of image names. A numeric
%                 value will be added to it.
%   imFnmExt      Extension of the file name (e.g., png).
%                 All formats readable by imread are allowed.
% Outputs:
%   compIm  [p x numOfIm]  Compound image. p denotes the
%                          total number of pixels in an individual 
%                          image, p=m*n, see below.
%   imsize  [m x n]  Size of the individual images.

% History:
% $Id: creDatMatFromIm_decor.m 1088 2007-08-16 06:34:55Z svoboda $
%
% 2007-07-05 V. Hlavac Written.
% 2007-08-09 T. Svoboda: refinenement for better look of m-files


disp('Starts creating compound data matrix from images.');

compIm = [];

for i = 1:numOfIm
    auxStr2 = int2str(i);
    if i <= 9
        auxStr2 = ['0',auxStr2];
    end
    FileNameStr = [imFnmBeg,auxStr2,'.',imFnmExt];
    fileInfo = imfinfo(FileNameStr);
    imWidth = fileInfo.Width;
    if (i > 1) && (imWidth ~= imWidthOld)
        error(['Error: Number of elements in a rows has changed ',FileNameStr, ...
                int2str(imWidth),' ',int2str(imWidthOld)]);
    end
    imWidthOld = imWidth;
    imHeight = fileInfo.Height;
    if (i > 1) && (imHeight ~= imHeightOld)
        error(['Error: Number of elements in a columns has changed ',FileNameStr,...
                int2str(imHeight),' ',int2str(imHeightOld)]);
    end
    imHeightOld = imHeight;

    % Read one image
    oneImage = imread(FileNameStr);
    disp(['Image ',FileNameStr,' read.']);

    % Create one vector of data per image. Columns of the image are
    % concatenated. This column vector is treated as a vector of
    %  measurements (features) where each pixel intensity is a measurement.
    oneLineImage = reshape(oneImage,imWidth*imHeight,1);
    doubleOneLineImage = double(oneLineImage);

    % Create compound matrix from individual images. Each column of the
    % composed matrix corresponds to one image reshaped to one column
    % vector. Later, e.g., in PCA, one column will be treated as an
    % instance of a stochastic process.
    compIm = [compIm doubleOneLineImage];

end % for all images
imsize = [imHeight, imWidth];
disp('Data matrix from images created');

return
