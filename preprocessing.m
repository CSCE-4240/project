% Read the image
img = imread('people.png'); 

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
filled = imfill(dilated, 'holes');

% Optional: Erode slightly to reduce over-expansion
processed = imerode(filled, se);

% Display results
figure;
subplot(2,3,1), imshow(img), title('Original');
subplot(2,3,2), imshow(gray), title('Grayscale');
subplot(2,3,3), imshow(denoised), title('Denoised');
subplot(2,3,4), imshow(blurred), title('Blurred');
subplot(2,3,5), imshow(edges), title('Edges');
subplot(2,3,6), imshow(processed), title('Final (Edges Fixed)');