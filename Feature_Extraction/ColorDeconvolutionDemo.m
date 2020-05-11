% color deconvolution project by Jakob Nikolas Kather, 2015
% url: https://github.com/jnkather/ColorDeconvolutionMatlab/blob/master/ColorDeconvolutionDemo.m
% contact: www.kather.me

format compact,

% set of standard values for stain vectors (from python scikit)
 He1 = [0.65; 0.70; 0.29];
 Eo = [0.07; 0.99; 0.11];
 DAB = [0.27; 0.57; 0.78];

% alternative set of standard values (HDAB from Fiji)
He = [ 0.6500286;  0.704031;    0.2860126 ];
DAB = [ 0.26814753;  0.57031375;  0.77642715];
Res = [ 0.7110272;   0.42318153; 0.5615672 ]; % residual

%%My own values for separating glom nuclei in our own mouse H&E images,
%%measured from image patches:
Hmouse = [173.9994; 195.6385; 159.0166];
Emouse = [59.1162; 166.8148; 139.6877];


%%To do H&E I pick two stains from the choices above, set the residual to
%%be orthogonal to them both, and normalize:
stain1 = Hmouse;
stain2 = Emouse;
Res = cross(stain1, stain2); 

% combine stain vectors to deconvolution matrix
HDABtoRGB = [stain1/norm(stain1) stain2/norm(stain2) Res/norm(Res)]'; %%For some reason it had 'DAB/norm(Res)'. Changed it.
RGBtoHDAB = inv(HDABtoRGB);
    
% separate stains = perform color deconvolution
%tic
imageout = SeparateStains(im, RGBtoHDAB);
%toc

%SB - commented out showing images of different stains

% % show images
% fig1 = figure();
% set(gcf,'color','w');
% subplot(1,4,1); imshow(im); title('Original');
% subplot(1,4,2); imshow(imageout(:,:,1)); title('Hematoxylin');
% subplot(1,4,3); imshow(imageout(:,:,2)); title('Eosin');
% subplot(1,4,4); imshow(imageout(:,:,3)); title('Residual');

%{
subplot(2,4,5); imhist(rgb2gray(imRGB)); title('Original');
subplot(2,4,6); imhist(imageHDAB(:,:,1)); title('Hematoxylin');
subplot(2,4,7); imhist(imageHDAB(:,:,2)); title('Eosin');
subplot(2,4,8); imhist(imageHDAB(:,:,3)); title('Residual');
%}


%{ 
% combine stains = restore the original image
 tic
 imRGB_restored = RecombineStains(imageHDAB, HDABtoRGB);
 toc
 fig2 = figure()
 subplot(2,2,1); imshow(imRGB); title('Orig');
 subplot(2,2,2); imshow(imRGB_restored); title('restored');
%%Doesn't quite do the trick, old man!
 %}