
ImageDir='images/';%directory containing the images
m=5;
n=5;

IM_original=imread([ImageDir 'chalet.jpg']);

tic
IM_out= medfilt(IM_original,m,n);
toc

tic
IM_out= medfilt2(IM_original,[m,n]);
toc

figure;
imshow(IM_original);title('ORIGINAL');
figure;
imshow(IM_out);title('MEDIAN FILTERED');