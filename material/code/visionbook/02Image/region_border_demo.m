% Region_border_demo Demonstration of inner and outer boundaries
% CMP Vision Algorithms, http://visionbook.felk.cvut.cz
% 

% History:
% $Id: region_border_demo_decor.m 1089 2007-08-16 07:09:03Z svoboda $
% 
% 2007-06-28 VH Written.
% 2007-07-07 VZ ', an example' has been removed from ch title
% 2007-08-15 TS output directory handling made consistent

clear all;
addpath ../.
cmpviapath('../.');
% create a directory for output images
% if needed and does not already exist
out_dir = 'output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir);
end


% Read input binary image from 
inpImageBW = imread('images/BoundExampleFig2-13.png');
fh = coarse_pixels_draw(inpImageBW, []);
title('Binary input image');
print('-depsc2', '-cmyk', [out_dir,'ObjectEllong2-13.eps']);
innerBound = bwperim(inpImageBW, 8);
figure
coarse_pixels_draw(inpImageBW, innerBound);
title('Inner boundary, 8-neighborhood');
print('-depsc2','-cmyk', [out_dir,'ObjectEllong2-13Inner8.eps']);
innerBound = bwperim(inpImageBW, 4);
figure
coarse_pixels_draw(inpImageBW, innerBound);
title('Inner boundary, 4-neighborhood');
print('-depsc2', '-cmyk', [out_dir,'ObjectEllong2-13Inner4.eps']);
negInpImageBW = ~inpImageBW;
innerBound = bwperim(negInpImageBW, 8);
figure
coarse_pixels_draw(negInpImageBW, innerBound);
title('Outer boundary, 8-neighborhood');
print('-depsc2', '-cmyk', [out_dir,'ObjectEllong2-13Outer8.eps']);
negInpImageBW = ~inpImageBW;
innerBound = bwperim(negInpImageBW, 4);
figure
coarse_pixels_draw(negInpImageBW, innerBound);
title('Outer boundary, 4-neighborhood');
print('-depsc2', '-cmyk', [out_dir,'ObjectEllong2-13Outer4.eps']);
