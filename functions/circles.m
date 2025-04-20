function [centers, radii] = circles(img)
    [centers, radii] = imfindcircles(img, [10 100], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92);
end