function output = fourier_transform(edges)
    %extract fourier coefficients
    fourierDescriptors = fft2(edges);
    output = fftshift(fourierDescriptors);
end