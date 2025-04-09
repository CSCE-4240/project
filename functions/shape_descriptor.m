function [centers, radii] = shape_descriptor(img)
    [centers, radii] = imfindcircles(img, [10 100], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92);
end