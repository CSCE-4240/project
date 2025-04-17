function output = preprocessing(img)
    % Convert to grayscale
    gray = rgb2gray(img);

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