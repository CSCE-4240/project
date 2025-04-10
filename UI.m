function UI
    % Create UI figure
    ui = uifigure('Name', 'Fourier Shape Descriptor', 'Position', [100 100 600 400]);
    addpath('functions'); 

    grid = uigridlayout(ui, [5, 2]);
    grid.RowHeight = {'3x', 30, 40, 30, 30}; 
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

    saveButton = uibutton(grid, 'push', 'Text', 'Save Reconstructed Image');
    saveButton.Layout.Row = 5;
    saveButton.Layout.Column = [1 2];
    saveButton.ButtonPushedFcn = @(src, event) saveImage(ax2,ui);
    saveButton.Enable = 'off';

    reconstructButton.ButtonPushedFcn = @(src,event) processImage(ax1, ax2, percentSlider.Value, saveButton);
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

function processImage(ax1, ax2, slider_value, saveButton)
    % Get the image from ax1 (the original)
    img = getimage(ax1);

    edges = preprocessing(img);
    fourier_descriptors = fourier_transform(edges);
    rec_img = reconstruction(fourier_descriptors, slider_value);
    [centers, radii] = shape_descriptor(rec_img);

    % Show original image in ax2
    imshow(rec_img, 'Parent', ax2);

    % Overlay detected circles
    hold(ax2, 'on');
    viscircles(ax2, centers, radii, 'EdgeColor', 'r');
    hold(ax2, 'off');
    saveButton.Enable = 'on';
end

function saveImage(image, ui)
    img = getimage(image);
    if(isempty(img))
        uialert(ui,"NO IMAGE");
        return;
    end
    [file, path] = uiputfile({'*.png'});
    imwrite(img, fullfile(path, file));
end
    
