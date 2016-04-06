function psnr = psnr(img1,img2)

width = size(img1,2);
height = size(img2,1);
diff = abs(double(img1) - double(img2));
ssd = sum(sum(diff.*diff));
psnr = 10*log10(width*height*255^2/ssd);
 

