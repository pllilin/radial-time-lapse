function [image] = createRadialTimelapse(imageBackground,imageFolder,imageList,anglesMatrix,deltan,NameValueArgs)
%createRadialTimelapse(imageBackground,imageList,anglesMatrix,deltan,resizeRatio,fadeAngle,startAngle,fadeType,totalAngle)
%Creates a radial timelapse from a serie of images: each slice of angle
%(theta, theta+delta theta) corresponds to the image at time t = tTotal/360
arguments
    imageBackground % should be resized previously (needed to get the correct xc,yc and thetaMatrix anyway)
    imageFolder {mustBeFolder}
    imageList struct % contains imageList.name
    anglesMatrix double
    deltan = 1
    NameValueArgs.resizeRatio double = 1
    NameValueArgs.startAngle double = 0
    NameValueArgs.fadeAngle double = 0
    NameValueArgs.fadeType double = 0 %0 for no fade, 1 for linear, 2 for quadratic
    NameValueArgs.timeScaling {mustBeMember(NameValueArgs.timeScaling,["linear","logarithmic","exponential","quadratic","depositWidth"])} = "linear"
    NameValueArgs.totalAngle double = 360 % not very useful - can obtain similar result by changing startAngle and the starting image, not compatible with fade-ins
    NameValueArgs.plotThetaIndex logical = False
end
resizeRatio = NameValueArgs.resizeRatio;
startAngle = NameValueArgs.startAngle;
fadeAngle = NameValueArgs.fadeAngle;
fadeType = NameValueArgs.fadeType;
totalAngle = NameValueArgs.totalAngle;
timeScaling = NameValueArgs.timeScaling;
plotThetaIndex = NameValueArgs.plotThetaIndex;

nImages = length(imageList);
N = fix(nImages / deltan);
deltaTheta = totalAngle / N; % by default totalAngle = 360
% deltaTheta will be redefined if time is logarithmic

nFade = fix(fadeAngle/deltaTheta); % number of images over which to do a fade-in
switch fadeType
    case 0
        fadeFactor = @(i) 1;
    case 1
        fadeFactor = @(i) min(1,i/nFade);
    case 2
        fadeFactor = @(i) (i<=nFade).*((nFade-1)^2-(nFade-i).^2)/(nFade-1)^2+(i>nFade)*1;
end

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

image = imageBackground;

for i=1:N
    theta = startAngle + getTheta(i);
    deltaTheta = getTheta(i+1)-getTheta(i);
    theta = mod(theta,360);
    
    n = nImages - (N-i)*deltan; % make sure that the last images are shown - important when specifying N and not deltan
    newImage = imread(imageFolder+imageList(n).name); % load and resize the image
    newImage = imresize(newImage,resizeRatio);
    
    % find the row and column numbers corresponding to the triangle of
    % angle (theta, theta + deltaTheta)
    if theta + deltaTheta > 360 % the triangular slice crosses the vertical
        [row,col] = find(anglesMatrix >= theta | anglesMatrix < mod(theta + deltaTheta,360));
    else
        [row,col] = find(anglesMatrix >= theta & anglesMatrix < theta + deltaTheta);
    end
    % paste the values from the image i unto the base image
    %     image(row,col,:) = newImage(row,col,:); % -> MATLAB cannot load the
    %     entire data at once and crashes, do row by row
    for k = 1:length(row)
        image(row(k),col(k),:) = (1-fadeFactor(i))*image(row(k),col(k),:) + fadeFactor(i)*newImage(row(k),col(k),:);
    end
end

if plotThetaIndex
    figure();
    plot(startAngle + getTheta(1:N), 1:N, '.')
    xlabel("\theta (degree)")
    ylabel("Image index")
end

end

