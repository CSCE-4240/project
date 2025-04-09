function output = reconstruction(F_shifted, percent)
    % Flatten, sort by magnitude, and find threshold
    flat_F = abs(F_shifted(:));
    sorted_magnitudes = sort(flat_F, 'descend');
    num_coeffs = floor((percent / 100) * numel(flat_F));
    threshold = sorted_magnitudes(num_coeffs);

    % Zero out small coefficients
    F_retained = F_shifted .* (abs(F_shifted) >= threshold);

    % Inverse shift and inverse FFT
    F_unshifted = ifftshift(F_retained);
    reconstructed = real(ifft2(F_unshifted));

    % Normalize for visualization
    output = mat2gray(reconstructed);
end