function UI
    % Create UI figure
    ui = uifigure('Name', 'Fourier Shape Descriptor', 'Position', [100 100 600 400]);
    addpath('functions'); 

    grid = uigridlayout(ui, [4, 2]);
    grid.RowHeight = {'3x', 30, 40, 30}; 
    grid.ColumnWidth = {'1x', '1x'};

    ax1 = uiaxes(grid);
    ax1.Layout.Row = 1;
    ax1.Layout.Column = 1;
    title(ax1, 'Input');

    ax2 = uiaxes(grid);
    ax2.Layout.Row = 1;
    ax2.Layout.Column = 2;
    title(ax2, 'Output');

    loadButton = uibutton(grid, 'push', 'Text', 'Load Image');
    loadButton.Layout.Row = 2;
    loadButton.Layout.Column = [1 2];

    % Button callback function
    loadButton.ButtonPushedFcn = @(src,event) loadImage(ax1);

    percentSlider = uislider(grid, 'Limits', [0 100], 'Value', 100);
    percentSlider.Layout.Row = 3;
    percentSlider.Layout.Column = [1 2];

    percentSlider.ValueChangedFcn = @(src, event) disp(['Slider value: ' num2str(src.Value)]);

    reconstructButton = uibutton(grid, 'push', 'Text', 'Reconstruct Image');
    reconstructButton.Layout.Row = 4;
    reconstructButton.Layout.Column = [1 2];

    reconstructButton.ButtonPushedFcn = @(src,event) processImage(ax1, ax2, percentSlider.Value);
end

function loadImage(ax)
    % Open file explorer to select image
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'});
    if file
        img = imread(fullfile(path, file));
        imshow(img, 'Parent', ax);
    else
        disp('No image selected');
    end
end

function processImage(ax1, ax2, slider_value)
    % Get the image from ax1 (the original)
    img = getimage(ax1);

    edges = preprocessing(img);
    fourier_descriptors = fourier_transform(edges);
    rec_img = reconstruction(fourier_descriptors, slider_value);
    [centers, radii] = circles(rec_img);
    [isPentagon, boundary] = pentagons(rec_img);

    % Show original image in ax2
    imshow(rec_img, 'Parent', ax2);
    
    %draw circles
    viscircles(ax2, centers, radii, 'EdgeColor', 'r');
    
    %if there is a pentagon, draw it
    if isPentagon
        line(ax2, boundary(:,2), boundary(:,1), 'Color', 'g', 'LineWidth', 3);
    end
end
