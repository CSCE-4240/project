function [rect_centers, rect_sizes] = detect_rect(img)
    % Convert the image to binary
    BW = imbinarize(uint8(img));
    
    % Label connected components in the binary image
    stats = regionprops(BW, 'BoundingBox', 'Area');
    
    rect_centers = [];
    rect_sizes = [];
    
    for i = 1:length(stats)
        % Filter based on area
        if stats(i).Area > 100  % Change threshold
            boundingBox = stats(i).BoundingBox;
            aspectRatio = boundingBox(3) / boundingBox(4);
           
            if aspectRatio > 0.5 && aspectRatio < 2  % You can adjust these values
                rect_centers = [rect_centers; boundingBox(1:2) + boundingBox(3:4) / 2]; % Center of rectangle
                rect_sizes = [rect_sizes; boundingBox(3:4)]; % Width and height of rectangle
            end
        end
    end
end