%IMTHRESH_TEST Test of the functionality of imthresh.m.
% CMP Vision Algorithms cmpvia@cmp.felk.cvut.cz
%
% Verifies the correctness of the output of imthresh.m:
%  - Verifies that the output is correct for a matrix of zeros and for a
%  matrix of ones (in both cases the output shoul be a matrix of ones since 
%  all values are equal or greater than the threshold) by displaying the
%  input and the output images.
%  - Displays  the result for an example real image.
%  - verifies, that the value of the threshold computed by imthresh.m is equal to:
%   ceil((mean(pixels1) + mean(pixels2))/2) ,
%   where pixels1 are pixels whose values are <threshold and pixels2 are
%   pixels whose values are >=threshold
%   It prints in the command line whether the output was correct or not.

% History
% $Id: $
%
% 2006-06 Petr Nemecek created 

ImageDir='images/';%directory containing the images

%a)verify the function on an whole-black image (the output should be
%all white - a matric of zeros, since all pixels should be above the threshold)
im_inp=uint8(zeros(3));
[im_out,threshold]=imthresh(im_inp);
figure;
subplot(1,2,1);
imshow(im_inp);title('input image');
subplot(1,2,2);
imshow(im_out);title('output image');
if im_out==ones(3);
    disp('Test for image of zeros OK.')
else 
    disp('CAUTION: Test for image of zeros INCORRECT!')
end

%b)verify the function on an whole-white image (the output should be
%all white - a matric of zeros, since all pixels should be above the threshold)
im_inp=uint8(ones(3));
[im_out,threshold]=imthresh(im_inp);
figure;
subplot(1,2,1);
imshow(im_inp);title('input image');
subplot(1,2,2);
imshow(im_out);title('output image');
if im_out==ones(3);
    disp('Test for image of ones OK.')
else 
    disp('CAUTION: Test for image of ones INCORRECT!')
end

%c)Verify the function on a normal image
% proof that the threshold lies almost at the mean of the means of the
% mean foreground and mean background values:
im_inp=imread([ImageDir 'keys_gray.jpg']);
[im_out,threshold]=imthresh(im_inp);
figure;
subplot(1,2,1);
imshow(im_inp);title('input image');
subplot(1,2,2);
imshow(im_out);title('output image');


threshold_verif=(mean(nonzeros((im_inp>=threshold).*double(im_inp)))+mean(nonzeros((im_inp<threshold).*double(im_inp))))/2;
if ceil(threshold_verif)==threshold
    disp('The value of the threshold computed by imthresh is OK.')
else
    disp('CAUTION.The value of the threshold computed by imthresh is INCORRECT!!!')
end;    
