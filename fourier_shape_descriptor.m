
function output = fourier_shape_detect(edge)

    x = real(edge);
    y = imag(edge);
    
    %create complex representation
    complexPoints = x + 1i * y;

    %perform Fourier Transform
    fourierDescriptors = fft(complexPoints);
end