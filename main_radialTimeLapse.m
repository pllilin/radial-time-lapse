%% Load the list of images
imageFolder = "ExampleData\"; % directory (folder) containing the images to be assembled. Must end with \ or /.

nStart = 1; % index of the first image to use in the radial time lapse
nEnd = 0; % number of images to skip at the end
% Example: if imageFolder contains 100 images labeled 1...100 but only images
% 8, 9... 90 should be used, then nStart = 8 and nEnd = 10


thetaStart = -90; % starting angle (the first image will be displayed at thetaStart). thetaStart = 0 correspond to the upper vertical axis
clockwiseDirection = true; % time increases in clockwise direction if true
angleFade = 0; % fading - usually leave at 0. If enabled, fading makes a smooth transition between the first and last image.
fadeType = 1; % fading - does not matter if angleFade = 0
timeScaling = 'linear'; % relationship between the display angle theta a the image number i
% options: "linear","logarithmic","exponential","quadratic"
totalAngle = 360; % if 180, the images will fit in a half circle, etc
decimateFactor = 1; % time decimation: only use 1 image every decimateFactor
resizeRatio = 1; % faster to resize before processing the data instead of using resizeRatio
imageList = dir(imageFolder+"*.jpg"); % if the images are not jpg, change jpg to the file type (for instance *.png)

% In case the files have names like im_001... im_999 -> im_1000..., 
% use nartsortfiles to sort correctly: 
% https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% imageList = natsortfiles(imageList); 

%% Show last image and pick center
imageEndName = imageList(end-nEnd).name;
imageBackground = imread(imageFolder+imageEndName);
imageBackground = imresize(imageBackground,resizeRatio); % if code takes too long on the full image

f1 = figure();
imshow(imageBackground)
title("Pick the center of the drop")
[xC,yC] = ginput(1);
xC = fix(xC);
yC = fix(yC);
% The edge of the drop is used to plot a line from the center to the edge
% of the drop in the video mode. The next lines can be commented out if
% only using image mode.
title("Pick the edge of the drop - used for video only")
[xR,yR] = ginput(1);
r = norm([xR-xC,yR-yC]); % Radius of the drop

close(f1);

%% Create the radial timelapse
%Create the matrix of angles
plotThetaIndexCurve = true; % show what angles correspond to what time

thetaMatrix = getAnglesMatrix(imageBackground,xC,yC);
if ~clockwiseDirection
    thetaMatrix = 360 - thetaMatrix; % go in the positive (anti-clockwise) direction 
end

% Create the radial timelapse
tic
image = createRadialTimelapse(imageBackground,imageFolder,imageList(nStart:decimateFactor:end-nEnd),thetaMatrix,...
    totalAngle = totalAngle, resizeRatio = resizeRatio, startAngle = thetaStart,...
    fadeAngle = angleFade, fadeType = fadeType, timeScaling = timeScaling, plotThetaIndex = plotThetaIndexCurve);
toc

f=figure();
imshow(image)

%% Save
resolution = 300; %ppi
saveFolder = "ExampleResult/";
fileName = "Example";
exportgraphics(f,saveFolder + fileName + "_circularReslice_Nstart_"+nStart+"Nend"+nEnd+"_angleStart"+thetaStart+"angleFade_"+angleFade+timeScaling+"time_resize"+resizeRatio+"totalAngle"+totalAngle+".png",'Resolution',resolution)

%% Create the radial timelapse video images: setup
% Video mode is still in progress - only works well for linear time scaling

%Create the matrix of angles
thetaMatrix = getAnglesMatrix(imageBackground,xC,yC);
rParam = [xC,yC,r]; % Center and Radius of the drop

% Calculate the fps of the video
fpsIn = 1/decimateFactor; % input the number of images per second here - 1 image per second for the example data
fpsOut = 30; % goal framerate, will be slightly modified by the code
tScale = 10; % >1 for playing faster than real life
NskippedFrames = ceil(tScale * fpsIn/fpsOut); % save every NskippedFrames frames
fpsOut = tScale * fpsIn / NskippedFrames;

%% Create and save the video
saveFolder = "ExampleResult/";
outputname = "ExampleVideo"+"_circularReslice_Nstart_"+nStart+"Nend"+nEnd+"_angleStart"+thetaStart+"angleFade_"+angleFade+timeScaling+"time_resize"+resizeRatio+"totalAngle"+totalAngle;

tic
image = createRadialTimelapseVideo(imageBackground,imageFolder,imageList(nStart:decimateFactor:end-nEnd),thetaMatrix,rParam,...
    totalAngle = totalAngle, startAngle = thetaStart,fps = fpsOut, NskippedFrames = NskippedFrames,...
    timeScaling = timeScaling, outputPath = saveFolder+outputname);
toc



