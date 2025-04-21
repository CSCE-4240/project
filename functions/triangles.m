function [centers, sizes] = triangles(reconstructedImg)
    centers = [];
    sizes = [];

    % Convert to grayscale if needed
    if size(reconstructedImg, 3) == 3
        gray = rgb2gray(reconstructedImg);
    else
        gray = reconstructedImg;
    end

    % Convert to binary image
    bw = imbinarize(gray);
    bw = imfill(bw, 'holes');
    bw = bwareaopen(bw, 50);  % Remove small objects/noise

    % Extract contours
    boundaries = bwboundaries(bw);

    for k = 1:length(boundaries)
        boundary = boundaries{k};

        % Skip small boundaries
        if length(boundary) < 20
            continue;
        end

        % Convert boundary to complex numbers
        contour = boundary(:,2) + 1i * boundary(:,1);

        % Get Fourier Descriptors
        fd = fft(contour);

        % Normalize by the second coefficient to make it scale-invariant
        fd = fd / abs(fd(2));

        % Use ratio of higher-order magnitudes to classify triangle
        ratio = sum(abs(fd(5:end))) / abs(fd(2));

        % Adjust this threshold as needed
        if ratio < 2.5
            % Bounding box and centroid
            stats = regionprops(poly2mask(boundary(:,2), boundary(:,1), size(bw,1), size(bw,2)), 'Centroid', 'BoundingBox');

            if ~isempty(stats)
                centers(end+1, :) = stats(1).Centroid;
                sizes(end+1, :) = stats(1).BoundingBox(3:4); % width, height
            end
        end
    end
end