function output = preprocessing(img)
    maxDimensions = 1024; % Set max dimensions
    [rows, cols, ~] = size(img);
    scale = min(1, maxDimensions / max(rows, cols));
    
    if scale < 1
        img = imresize(img, scale);
    end

    % Convert to grayscale
    if(size(img, 3)) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    % Apply median filter for noise reduction
    denoised = medfilt2(gray, [3 3]);

    % Apply Gaussian blur
    h = fspecial('gaussian', [5 5], 1); % [size], sigma
    blurred = imfilter(denoised, h, 'replicate');

    % Edge detection
    edges = edge(blurred, 'Canny');

    % Dilate edges to connect incomplete shapes
    se = strel('disk', 2); % Structural element
    dilated = imdilate(edges, se);

    % Fill in shapes
    %filled = imfill(dilated, 'holes');

    % Optional: Erode slightly to reduce over-expansion
    output = imerode(dilated, se);
end