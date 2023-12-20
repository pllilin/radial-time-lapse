function [image] = createRadialTimelapseVideo(imageBackground,imageFolder,imageList,anglesMatrix,rParam,deltan,NameValueArgs)
%createRadialTimelapse(imageBackground,imageList,anglesMatrix,deltan,resizeRatio,fadeAngle,startAngle,fadeType,totalAngle)
%Creates a radial timelapse from a serie of images: each slice of angle
%(theta, theta+delta theta) corresponds to the image at time t = tTotal/360
% Mostly works for linear time. For non-linear timing need to separate when
% data is added and when the frame is written to video
arguments
    imageBackground % uint8 - should be resized previously (needed to get the correct xc,yc and thetaMatrix anyway)
    imageFolder {mustBeFolder}
    imageList struct % contains imageList.name
    anglesMatrix double
    rParam double = 0
    deltan = 1
    NameValueArgs.resizeRatio double = 1
    NameValueArgs.startAngle double = 0
    NameValueArgs.timeScaling {mustBeMember(NameValueArgs.timeScaling,["linear","logarithmic","exponential","quadratic","depositWidth"])} = "linear"
    NameValueArgs.totalAngle double = 360 
    NameValueArgs.outputPath string = "radialTimeLapse";
    NameValueArgs.NskippedFrames = 1
    NameValueArgs.fps = 10;
    
end
resizeRatio = NameValueArgs.resizeRatio;
startAngle = NameValueArgs.startAngle;
totalAngle = NameValueArgs.totalAngle;
timeScaling = NameValueArgs.timeScaling;
outputPath = NameValueArgs.outputPath;
NskippedFrames = NameValueArgs.NskippedFrames;
fps = NameValueArgs.fps;

pbar=waitbar(0,'Initializing');

nImages = length(imageList);
N = fix(nImages / deltan);

if timeScaling == "logarithmic"
    getTheta = @(i) totalAngle * log(i)/log(N+1); % =0 at i=1, =360 at i=N+1
elseif timeScaling == "exponential"
    getTheta = @(i) (exp((i-1)/N*log(totalAngle+1))-1);
elseif timeScaling == "quadratic"
    getTheta = @(i) totalAngle * (i-1)^(2)/(N)^(2);
elseif timeScaling == "depositWidth"
    getTheta = @(i) totalAngle * (1-sqrt(1-(i-1)/N));
else % linear
    getTheta = @(i) totalAngle * (i-1)/N;
end

% Initialize (not really necessary)
image = imageBackground*0;

% Create a figure - needed to plot the black line going around
f=figure('visible','off'); % make it invisible 

% Initialize the video
v = VideoWriter(outputPath+".mp4",'MPEG-4');
v.FrameRate = fps; % Set framerate
open(v)

for i=1:N
    theta = startAngle + getTheta(i);
    theta = mod(theta,360);
    
    n = nImages - (N-i)*deltan; % make sure that the last images are shown - important when specifying N and not deltan
    newImage = imread(imageFolder+imageList(n).name); % load and resize the image
    newImage = imresize(newImage,resizeRatio);
    
    % find the row and column numbers corresponding to all angles > theta
    
    % Find the segment [theta, startAngle] on the circle [0,360]
    if theta >= mod(startAngle,360)
        [row,col] = find(anglesMatrix >= theta | anglesMatrix < mod(startAngle,360));
    else
        [row,col] = find(anglesMatrix >= theta & anglesMatrix < mod(startAngle,360));
    end
    % paste the values from the image i unto the base image
    for k = 1:length(row)
        image(row(k),col(k),:) = newImage(row(k),col(k),:);
    end
    
    if mod(i-1,NskippedFrames) == 0 %i-1 so that for i=1, mod(i-1,...) = 0 so the first image is saved
        % Save - adding a line to indicate how far the video has gone
        imshow(image)
        hold on
        % Draw a line
        if length(rParam)>1
            plot([rParam(1),rParam(1)+rParam(3)*cosd(theta+startAngle)],[rParam(2),rParam(2)+rParam(3)*sind(theta+startAngle)],'-k')     
        end
        hold off
        writeVideo(v,getframe(f));
        % Slightly faster option without using a figure, cannot draw a line
%         writeVideo(v,image); 
        waitbar(double(i)/N,pbar,sprintf('Image %i out of %i',i,N)); % Update the wait bar

    end
end

% ensure that last image is written
imshow(newImage) % last image
hold on
% Draw a line
if length(rParam)>1
    plot([rParam(1),rParam(1)+rParam(3)*cosd(startAngle)],[rParam(2),rParam(2)+rParam(3)*sind(startAngle)],'-k')
end
hold off
writeVideo(v,getframe(f));

close(v);
close(pbar);
end

