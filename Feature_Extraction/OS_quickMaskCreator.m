% To hand-draw a region of interest and create a mask from it:

figure(1), imshow(im);
h = imfreehand;
Mask = h.createMask();
close
%figure, imshow(M)