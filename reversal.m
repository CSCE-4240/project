% this example function reconstructs an image using the 2D Fourier Transform

function reconstructed_image = reconstructImage(image_path)
    % read a grayscale image
    original_image = imread(image_path);
    if size(original_image, 3) == 3
        original_image = rgb2gray(original_image); % Convert to grayscale if RGB
    end

    % convert to double for processing the image
    original_image = double(original_image);

    % complete the 2D fourier transform
    freq_domain = fft2(original_image);

    % teconstruct the image using inverse 2D fourier transform
    reconstructed_image = ifft2(freq_domain); % the actual line of code we will be using

    % take the real part and convert back to uint8 for display
    reconstructed_image = uint8(real(reconstructed_image));

    % display original and reconstructed images
    figure;
    subplot(1,2,1), imshow(uint8(original_image)), title('Original Image');
    subplot(1,2,2), imshow(reconstructed_image), title('Reconstructed Image');
end
