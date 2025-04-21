function [rect_centers, rect_sizes] = rectangles(reconstructedImg)
    % Binarize reconstructed image
    bw = imbinarize(reconstructedImg);

    % Extract object boundaries
    boundaries = bwboundaries(bw);

    rect_centers = [];
    rect_sizes = [];

    for k = 1:length(boundaries)
        boundary = boundaries{k};

        % Convert (row, col) to complex numbers
        z = boundary(:,2) + 1i * boundary(:,1);

        % Get Fourier descriptors
        fd = fft(z);

        % Normalize
        if abs(fd(2)) < 1e-6
            continue; % Avoid division by zero
        end

        % Element wise division
        fd = fd ./ abs(fd(2));  

        % Keep low-frequency descriptors only
        numDesc = 10;
        fdReduced = zeros(size(fd));
        fdReduced(1:min(numDesc, length(fd))) = fd(1:min(numDesc, length(fd)));

        % Reconstruct shape
        zRecon = ifft(fdReduced);
        xRecon = real(zRecon);
        yRecon = imag(zRecon);

        energyRatio = sum(abs(fd(3:end))) / abs(fd(2));

        if energyRatio < 1
            x = boundary(:,2);
            y = boundary(:,1);
            minX = min(x); maxX = max(x);
            minY = min(y); maxY = max(y);

            center = [(minX + maxX)/2, (minY + maxY)/2];
            sizeVal = [maxX - minX, maxY - minY];

            rect_centers = [rect_centers; center];
            rect_sizes = [rect_sizes; sizeVal];
        end
    end
end


%{
img = imread('squares.png');
edges = preprocessing(img);
fourierDescriptors = fourier_transform(edges);
reconstructedImg = reconstruction(fourierDescriptors, 100);

[centers, sizes] = detect_rect(reconstructedImg);

figure;
imshow(reconstructedImg);
hold on;

for i = 1:size(centers, 1)
    center = centers(i, :);
    sizeVal = sizes(i, :);
    x = center(1) - sizeVal(1)/2;
    y = center(2) - sizeVal(2)/2;

    rectangle('Position', [x, y, sizeVal(1), sizeVal(2)], ...
              'EdgeColor', 'r', 'LineWidth', 2);
end
%}