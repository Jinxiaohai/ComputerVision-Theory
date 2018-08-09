% PREPARE_TEXTURE_DATA for haralick_demo
% CMP Vision Algorithms http://visionbook.felk.cvut.cz

ImageDir='images/'; %directory containing the images
addpath('..') ;
cmpviapath('..') ;

% Each texture sample is converted to a grayscale uint8 image and 
% cut to 36 non-overlapping patches 
% 100x 100 pixels. Each patch is  assigned a label indicating
% its class 1... 10.

files = {'D101' 'D110' 'D112' 'D16' 'D17' 'D21' 'D3' 'D4' 'D67' 'D95'};
patchsize = 100;
textures = struct([]);
ind = 1;
for i = 1:size(files,2)
  fn = files{i};
  img = im2uint8( imread([ImageDir fn '.png']) );
  if size(img,3)>1, img = rgb2gray(img); end
  [ny,nx] = size(img);
  for ox = 1:patchsize-1:nx-patchsize+1
    for oy = 1:patchsize-1:ny-patchsize+1
      textures(ind).patch = img( oy:oy+patchsize-1, ox:ox+patchsize-1 );
      textures(ind).class = i;
      ind = ind+1;
    end
  end
end

% The samples are randomly permuted and divided into training and testing data.
% Note that because the permutation is global, the number of training
% examples per class may not be the same for all classes. This might lead
% to slightly suboptimal classification results but corresponds to
% a realistic scenario.

n = ind-1;
textures = textures( randperm(n) );

textures_train = textures( 1:n/2 );
textures_test = textures( n/2+1:end );

save textures textures_train textures_test
