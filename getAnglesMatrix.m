function thetaMatrix = getAnglesMatrix(image,xC,yC,angleStart)
%getAnglesMatrix(image,xC,yC,angleStart) Returns a matrix of the same size
%as image where thetaMatrix(i,j) is the angle (in degrees) between the
%vertical (if angleStart =90) and (i,j), measured clockwise. The center
%from which angles are calculated is (xC,yC).
arguments
    image
    xC double 
    yC double
    angleStart double = 90
end

sizeX = size(image,2);
sizeY = size(image,1);
xMatrix = repmat([1:sizeX]-xC,sizeY,1);
yMatrix = repmat([1:sizeY]'-yC,1,sizeX);
thetaMatrix = atan2d(yMatrix,xMatrix);
thetaMatrix = thetaMatrix + angleStart; % measure angle starting from the vertical
thetaMatrix = mod(thetaMatrix,360); % angles between 0 and 360

end

