%% Real Time SURF Features and Tracking Using Simple Webcam
% You can use your reference image. 

%% Load reference image, detect SURF points, and extract descriptors
clear;
warning('off');
referenceimage = imread('d.jpg'); 

%% Detect and extract SURF features 
referenceimageGray = rgb2gray(referenceimage); 
referencePts = detectSURFFeatures(referenceimageGray); 
referenceFeatures = extractFeatures(referenceimageGray, referencePts); 
 
%% Prepare video input from webcam 
camera = webcam('USB Camera'); 
set(camera, 'Resolution', '640x480'); 

%% Detect SURF features in webcam frame
set(gcf, 'Position', get(0, 'Screensize'));

NR=200;% Number of repeats 
for i=1:NR

cameraFrame = snapshot(camera); 
cameraFrameGray = rgb2gray(cameraFrame);
cameraPts = detectSURFFeatures(cameraFrameGray); 
% imshow(cameraFrame), hold on;
% plot(cameraPts.selectStrongest(50)); 

%% Try to match the reference image and camera frame features 
cameraFeatures = extractFeatures(cameraFrameGray, cameraPts); 
idxPairs = matchFeatures(cameraFeatures, referenceFeatures); 
% Store the SURF points that were matched 
matchedCameraPts = cameraPts(idxPairs(:,1)); 
matchedReferencePts = referencePts(idxPairs(:,2)); 

%% Get geometric transformation between reference image and webcam frame
[referenceTransform, inlierReferencePts, inlierCameraPts] ...
    = estimateGeometricTransform( matchedReferencePts, matchedCameraPts, 'similarity'); 
% Show the inliers of the estimated geometric transformation
% Plots
polish=sharppolished(cameraFrameGray);
subplot(2,2,1)
imshow(cameraFrame); title('WebCam');
subplot(2,2,2)
imshow(cameraFrame), hold on;
plot(inlierCameraPts.selectStrongest(100)); title('SURF Features');
subplot(2,2,3)
imshow(cameraFrameGray);title('Gray Level');
subplot(2,2,4)
imshow(polish); title('Edges');
end

%% Final cleanup
delete(camera);
