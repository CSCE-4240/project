function [isTriangle, boundaries] = triangles(edges)


    % Clean up small artifacts and fill holes
    binaryImg = bwareaopen(edges, 100);
    binaryImg = imfill(binaryImg, 'holes');

    % Label connected components and measure properties
    [labeledImg, numObjects] = bwlabel(binaryImg);
    stats = regionprops(labeledImg, 'Perimeter');

    isTriangle = false(numObjects, 1);
    boundaries = cell(numObjects, 1);

    % Display the cleaned binary image
    figure;
    imshow(binaryImg);
    hold on;

    for i = 1:numObjects
        % Extract object boundary
        currentObj = (labeledImg == i);
        B = bwboundaries(currentObj);
        boundary = B{1};
        perimeter = stats(i).Perimeter;

      
        epsilon = 0.02 * perimeter;
        approxCurve = approxPolygon(boundary, epsilon);
        numVertices = size(approxCurve, 1);

        % Check for triangle: exactly 3 vertices and angle consistency
        if numVertices == 3
            angles = zeros(3,1);
            for j = 1:3
                p1 = approxCurve(j, :);
                p2 = approxCurve(mod(j,3) + 1, :);
                p3 = approxCurve(mod(j+1,3) + 1, :);
                v1 = p1 - p2;
                v2 = p3 - p2;
                angles(j) = acosd(dot(v1, v2) / (norm(v1) * norm(v2)));
            end
            avgAngle = mean(angles);
            angleStd = std(angles);
        
            if avgAngle > 40 && avgAngle < 80 && angleStd < 20
                isTriangle(i) = true;
                boundaries{i} = boundary;
                % Highlight triangle in red
                plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 3);
            end
        end
    end
end

function approxCurve = approxPolygon(curve, epsilon)
    
    if size(curve, 1) <= 2
        approxCurve = curve;
        return;
    end
    startPt = curve(1, :);
    endPt = curve(end, :);
    % Find max distance
    dists = arrayfun(@(i) pointToLineDistance(curve(i,:), startPt, endPt), 2:size(curve,1)-1);
    [maxDist, idx] = max(dists);
    idx = idx + 1;
    if maxDist > epsilon
      
        part1 = approxPolygon(curve(1:idx, :), epsilon);
        part2 = approxPolygon(curve(idx:end, :), epsilon);
        approxCurve = [part1(1:end-1, :); part2];
    else
        approxCurve = [startPt; endPt];
    end
end

function dist = pointToLineDistance(point, lineStart, lineEnd)
    % Perpendicular distance from a point to a line segment
    if isequal(lineStart, lineEnd)
        dist = norm(point - lineStart);
        return;
    end
    lineVec = lineEnd - lineStart;
    ptVec = point - lineStart;
    t = dot(ptVec, lineVec) / dot(lineVec, lineVec);
    t = max(0, min(1, t));
    proj = lineStart + t * lineVec;
    dist = norm(point - proj);
end
