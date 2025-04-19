function [centers, radii, triangles] = shape_descriptor(img)
    % This function detects circles and triangles in an image.
    % It uses the Hough transform for circles and convex hull for triangles.
    % The function returns the centers and radii of detected circles,
    % and the vertices of detected triangles.


 
    BW = imbinarize(img);          % binarize the image
    BW = imfill(BW,'holes');       % fill holes in the binary image
    BW = bwareaopen(BW,50);        % remove small objects

    
    % Circle detection via Hough transform
    [centers, radii] = imfindcircles(BW, [10 100], ...
                                     'ObjectPolarity','bright', ...
                                     'Sensitivity',0.92);

    % Triangle detection via convex hull
    stats     = regionprops(BW, 'ConvexHull');
    triangles = {};
    for s = stats'
        hull = s.ConvexHull;       
        if size(hull,1)==3          
            triangles{end+1} = hull;
        end
    end

    % Draw them 
    imshow(img); hold on
    viscircles(centers, radii, 'EdgeColor','b');
    for t = triangles
        h = t{1};
        % close the loop
        h(end+1,:) = h(1,:);
        plot(h(:,1), h(:,2), 'r-', 'LineWidth',2);
    end
    hold off
end
