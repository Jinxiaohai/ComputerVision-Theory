% demonstration of HIST_EQUAL, histogram equalization
% CMP Vision Algorithms http://visionbook.felk.cvut.cz
% Tomas Svoboda, 2006-2007

% $Id: hist_equal_demo_decor.m 1074 2007-08-14 09:45:42Z kybic $

addpath ../.
cmpviapath('../.');
% create a directory for output images
% if necessary, and does not already exist
out_dir = './output_images/';
if (exist(out_dir)~=7)
  mkdir(out_dir)
end

im = imread('images/raising_moon_gray_small.jpg');
[im_out,H,Hc,T] = hist_equal(im);

figure(1), clf
imshow(im)
title('Input image');
imwrite(im,[out_dir,'histeq_input.jpg']);

figure(2), clf
bar([0:length(H)-1],H)
title('histogram of the input image')
xlabel('intensity')
ylabel('frequency')
axis([0 length(H)-1, 0 max(H)])
exportfig(gcf, [out_dir,'histeq_histinput.eps']);

figure(3), clf
stairs([0:length(Hc)-1],Hc)
title('cumulative histogram of the input image')
xlabel('intensity')
ylabel('cumulative sum of the occurence')
grid on

figure(4), clf
val = 45;
plot([0:length(T)-1],T,'LineWidth',2)
title('Intensity trasformation (normalized cumulative histogram)')
xlabel('intensity in the input image')
ylabel('intensity in the output image')
hold on
stem(val-1,T(val),'Color','red')
line([0,val-1],[T(val),T(val)],'Color','red')
grid on;
h = text(80,150,sprintf('All pixels with intensity %d will have',val-1),'FontSize',12);
set(h,'BackgroundColor','white')
h = text(80,125,sprintf('the intensity %d in the output image',T(val)),'FontSize',12);
set(h,'BackgroundColor','white')
axis([0 255 0 255])

exportfig(gcf,[out_dir,'histeq_lookup.eps'])

figure(7), clf
hold on
sc=255/max(H);
h=bar([0:length(H)-1],H*sc,1);
set(h,'EdgeColor','none','FaceColor','b')
histnew = hist(im_out(:),[0:255]);
sc=255/max(histnew);
h=barh([0:255],histnew*sc,1);
set(h,'EdgeColor','none','FaceColor','g')
stairs([0:length(T)-1],T,'-r','LineWidth',3)
xlabel('intensity in the input image')
ylabel('intensity in the output image')
axis([0 255 0 255])
grid on
legend('input histogram','output histogram','transformation function')
title('Change of the histograms')
exportfig(gcf,[out_dir,'histeq_histtransf.eps'])

figure(5), clf
imshow(im_out)
title('Equalized image');
imwrite(im_out,[out_dir,'histeq_output.jpg']);

figure(6), clf
H_out = hist(im_out(:),[0:255]);
bar([0:255],H_out)
title('histogram of the output image')
xlabel('intensity')
ylabel('frequency')
axis([0 255 0 max(H_out)])
exportfig(gcf,[out_dir,'histeq_outhist.eps']);

figure(2), hold on
bar([0:255],hist(im_out(:),[0:255]),'g')
title('histogram of the input image [blue] and output image [green]')
exportfig(gcf,[out_dir,'histeq_bothhists.eps']);

