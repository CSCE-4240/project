function [isPentagon, boundary] = pentagons(rec_img)
    
    %normalize the image
    grayImg = mat2gray(rec_img);
    
    
    %create binary image
    binaryImg = imbinarize(grayImg, 'adaptive', 'Sensitivity', 0.4);
    
    %enhance edges
    binaryImg = bwmorph(binaryImg, 'thin', Inf);
    binaryImg = bwmorph(binaryImg, 'clean');
    
    %invert if needed
    if mean(binaryImg(:)) > 0.5
        binaryImg = ~binaryImg;
    end
    
    %clean up binary image
    binaryImg = bwareaopen(binaryImg, 100);
    binaryImg = imfill(binaryImg, 'holes');
    
    %find all shapes
    [labeledImg, numObjects] = bwlabel(binaryImg);
    stats = regionprops(labeledImg, 'Area', 'Centroid', 'BoundingBox', 'Perimeter', 'Solidity');
    
    %check all shapes for pentagon-like properties
    for i = 1:numObjects
        %get shape properties
        area = stats(i).Area;
        perimeter = stats(i).Perimeter;
        solidity = stats(i).Solidity;
        
        %calculate shape metrics
        circularity = 4 * pi * area / (perimeter^2);
        
        %get the shape boundary
        currentObj = (labeledImg == i);
        boundary = bwboundaries(currentObj);
        boundary = boundary{1};
        
        %try to estimate number of sides by polygon approximation
        epsilon = 0.02 * perimeter;
        approxCurve = approxPolygon(boundary, epsilon);
        vertices = size(approxCurve, 1);
        
        %calculate average angle if we have 5 vertices
        isRegularPentagon = false;
        angleStdDev = Inf;
        
        if vertices == 5
            %calculate angles between consecutive vertices
            angles = zeros(5, 1);
            for j = 1:5
                p1 = approxCurve(j, :);
                p2 = approxCurve(mod(j, 5) + 1, :);
                p3 = approxCurve(mod(j+1, 5) + 1, :);
                
                v1 = p1 - p2;
                v2 = p3 - p2;
                
                %calculate angle in degrees
                angle = acosd(dot(v1, v2) / (norm(v1) * norm(v2)));
                angles(j) = angle;
            end
            
            %check angle consistency - for a regular pentagon, interior angles should be ~108°
            angleStdDev = std(angles);
            avgAngle = mean(angles);
            
            %for a regular pentagon, interior angles are 108 degrees
            isRegularPentagon = (avgAngle > 100 && avgAngle < 116 && angleStdDev < 15);
        end
        
        isPentagon = false;
        
        if vertices == 5 && circularity > 0.75 && circularity < 0.9 && solidity > 0.85
            isPentagon = true;
            
            %if we have angle information, use it to refine detection
            if isRegularPentagon
                isPentagon = true;
            elseif angleStdDev > 25  %too much angle variation
                isPentagon = false;
            end
        end
        
        %allow a small tolerance for vertex count IF the shape is very pentagon-like
        if vertices == 4 || vertices == 6
            if circularity > 0.80 && circularity < 0.88 && solidity > 0.9
                isPentagon = true;
            end
        end
    end
end

function approxCurve = approxPolygon(curve, epsilon)
    %find the point with the maximum distance from line between start and end
    if size(curve, 1) <= 2
        approxCurve = curve;
        return;
    end
    
    %calculate line from start to end
    startIdx = 1;
    endIdx = size(curve, 1);
    
    startPoint = curve(startIdx,:);
    endPoint = curve(endIdx,:);
    
    %find the point with max distance
    maxDist = 0;
    maxIdx = 0;
    
    for i = startIdx+1:endIdx-1
        dist = pointToLineDistance(curve(i,:), startPoint, endPoint);
        if dist > maxDist
            maxDist = dist;
            maxIdx = i;
        end
    end
    
    %if max distance is greater than epsilon, recursively simplify
    if maxDist > epsilon
        %recursive call
        approxCurve1 = approxPolygon(curve(startIdx:maxIdx,:), epsilon);
        approxCurve2 = approxPolygon(curve(maxIdx:endIdx,:), epsilon);
        
        %combine results (avoid duplicating the splitting point)
        approxCurve = [approxCurve1(1:end-1,:); approxCurve2];
    else
        %if max distance is less than epsilon, use just the endpoints
        approxCurve = [startPoint; endPoint];
    end
end

function dist = pointToLineDistance(point, lineStart, lineEnd)
    %calculate the perpendicular distance from a point to a line
    if isequal(lineStart, lineEnd)
        dist = norm(point - lineStart);
        return;
    end
    
    %line vector
    lineVec = lineEnd - lineStart;
    
    %vector from line start to point
    pointVec = point - lineStart;
    
    %line length squared
    lineLengthSq = sum(lineVec.^2);
    
    %calculate projection
    proj = sum(pointVec .* lineVec) / lineLengthSq;
    
    %clamp projection to line segment
    proj = max(0, min(1, proj));
    
    %calculate nearest point on line
    nearestPoint = lineStart + proj * lineVec;
    
    %calculate distance
    dist = norm(point - nearestPoint);
end