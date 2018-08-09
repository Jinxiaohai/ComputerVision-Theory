function im_out=medfilt(im_inp,M,N);





iptchecknargin(3,3,nargin,mfilename);
iptcheckinput(im_inp, {'numeric','logical'}, {'2d','real'}, mfilename, 'im_inp', 1);
if any([M N]>size(im_inp))
  error('The size of the median window has to be smaller than the image size.');
end



im_out =uint8(zeros(size(im_inp)));
x=floor(M/2);
Window=zeros(M,N);
th=(M*N)/2;

while (x+floor(M/2))<size(im_inp,1);%8
   
    %2)
    %Position the window at the beginning of the new row:
    x=x+1;
    y=ceil(N/2);
    Window=im_inp(x-floor(M/2):x+floor(M/2),y-floor(N/2):y+floor(N/2));

    %Construct a histogram 'H' of the window pixels:
    %The first element of H corresponds to the greyscale value 0, therefore the number of pixels with grayscale value=x 
    %is in the (x+1)th element of H.  
    H = imhist(Window);
    
    %Determine the median 'med':
    med = median(Window(:));
    im_out(x,y) =med;
    
    
    %Record 'lt_med', the number of pixels with intensity less than 'med':
       lt_med=sum(H(1:med));
    

    %7) Repeat until the right-hand column of the window is at the right-hand edge of the image:
    while (y+floor(N/2))<size(im_inp,2);
        %3)
        %Remove the values of the rightmost column from the histogram and adjust
        %lt_med:
        for i=1:M
            H(Window(i,1)+1)=H(Window(i,1)+1)-1;
            if Window(i,1)<med
                lt_med =lt_med-1;
            end
        end

        %4) Move the window one column right. 
        y=y+1;
        Window=im_inp(x-floor(M/2):x+floor(M/2),y-floor(N/2):y+floor(N/2));

        %Add the values of the rightmost column in the histogram and adjust
        %lt_med:
        for i=1:M
            H(Window(i,end)+1)= H(Window(i,end)+1) + 1;
            if Window(i,end) <med
               lt_med =lt_med+1;
            end
        end

        if lt_med <= th%rovnost nemuze u licheho poctu pixelu nastat
            while lt_med + H(med+1)<= th
                lt_med=lt_med+H(med+1);
                med=med+1;
            end

        else %lt_med >th
            %6)if lt_med > th, decrement med and adjust lt_med:
            while lt_med> th
                med=med-1;
                lt_med=lt_med-H(med+1);
            end


        end
            im_out(x,y) =med;
    end
end

