function UI
    % Create UI figure
    ui = uifigure('Name', 'Fourier Shape Descriptor', 'Position', [100 100 600 400]);
    ui.Color = [0.1 0.1 0.1];
    addpath('functions'); 

    grid = uigridlayout(ui, [5, 2]);
    grid.RowHeight = {'3x', 30, 30, 'fit','fit'}; 
    grid.ColumnWidth = {'1x', '1x'};
    grid.BackgroundColor = [0.1 0.1 0.1];
    grid.Padding = [15 10 15 10];
    grid.RowSpacing = 8;
    grid.ColumnSpacing = 8;

    ax1 = uiaxes(grid);
    ax1.Layout.Row = 1;
    ax1.Layout.Column = 1;
    title(ax1, 'Input');
    ax1.XTick = [];
    ax1.YTick = [];
    ax1.Color = [0.15 0.15 0.15];
    ax1.XColor = 'none';
    ax1.YColor = 'none';
    ax1.Title.Color = 'w';
    ax1.Box = 'off';
    ax1.Title.FontName = 'Segoe UI';
    ax1.Title.FontSize = 18;
    
    ax2 = uiaxes(grid);
    ax2.Layout.Row = 1;
    ax2.Layout.Column = 2;
    title(ax2, 'Output');
    ax2.XTick = [];
    ax2.YTick = [];
    ax2.Color = [0.15 0.15 0.15];
    ax2.XColor = 'none';
    ax2.YColor = 'none';
    ax2.Title.Color = 'w';
    ax2.Title.FontName = 'Segoe UI';
    ax2.Title.FontSize = 18;

    buttonGrid = uigridlayout(grid,[1,3]);
    buttonGrid.Layout.Row = 2;
    buttonGrid.Layout.Column=[1 2];
    buttonGrid.ColumnWidth = {'1x', '1x','1x'};
    buttonGrid.Padding = [0 0 0 0];
    buttonGrid.ColumnSpacing = 10;
    buttonGrid.BackgroundColor = [0.1 0.1 0.1];

    loadButton = uibutton(buttonGrid, 'push', 'Text', '📂 Load Image');
    loadButton.Layout.Row = 1;
    loadButton.Layout.Column = 1;
    loadButton.BackgroundColor = [0.2 0.2 0.2];
    loadButton.FontColor = 'w';
    loadButton.FontName = 'Segoe UI';
    loadButton.FontSize = 12;

    % Button callback function
    loadButton.ButtonPushedFcn = @(src,event) loadImage(ax1);

    sliderGrid = uigridlayout(grid,[1,2]);
    sliderGrid.Layout.Row = 3;
    sliderGrid.Layout.Column = [1 2];
    sliderGrid.RowHeight = {'1x'}; 
    sliderGrid.ColumnWidth = {'1x', 30};
    sliderGrid.Padding = [0 0 0 0];
    sliderGrid.ColumnSpacing = 5;
    sliderGrid.BackgroundColor = [0.1 0.1 0.1];


    sliderLabel = uilabel(sliderGrid,'HorizontalAlignment','right','Text','100%');
    sliderLabel.Layout.Row = 1;
    sliderLabel.Layout.Column = 2;
    sliderLabel.FontColor = 'w';
    sliderLabel.FontName = 'Segoe UI';
    sliderLabel.FontSize = 12;


    percentSlider = uislider(sliderGrid, 'Limits', [0 100], 'Value', 100, 'ValueChangingFcn', @(src,event) updateSlider(event.Value,sliderLabel));
    percentSlider.Layout.Row = 1;
    percentSlider.MajorTicks = [];
    percentSlider.MinorTicks = [];
    percentSlider.Layout.Column = 1;

    percentSlider.FontColor = 'w';
    percentSlider.FontName = 'Segoe UI';
    percentSlider.FontSize = 12;

    reconstructButton = uibutton(buttonGrid, 'push', 'Text', 'Reconstruct Image');
    reconstructButton.Layout.Row = 1;
    reconstructButton.Layout.Column = 2;
    reconstructButton.BackgroundColor = [0.1 0.4 0.7];
    reconstructButton.FontColor = 'w';
    reconstructButton.FontName = 'Segoe UI';
    reconstructButton.FontSize = 12;

    saveButton = uibutton(buttonGrid, 'push', 'Text', '💾Save Reconstructed Image');
    saveButton.Layout.Row = 1;
    saveButton.Layout.Column = 3;
    saveButton.ButtonPushedFcn = @(src, event) saveImage(ax2,ui);
    saveButton.Enable = 'off';
    saveButton.BackgroundColor = [0.2 0.2 0.2];
    saveButton.FontColor = 'w';
    saveButton.FontName = 'Segoe UI';
    saveButton.FontSize = 12;

    shapeTitle = uilabel(grid,'Text','Shape Selection');
    shapeTitle.Layout.Row = 4;
    shapeTitle.Layout.Column = [1 2];
    shapeTitle.FontName = 'Segoe UI';
    shapeTitle.FontSize = 12;
    shapeTitle.FontColor = 'w';

    shapeSelection = uipanel(grid);
    shapeSelection.BackgroundColor = [0.1 0.1 0.1];
    shapeSelection.Layout.Row = 5;
    shapeSelection.Layout.Column = [1 2];

    checkGrid = uigridlayout(shapeSelection, [1, 4]);
    checkGrid.RowHeight = {'fit'};
    checkGrid.ColumnWidth = {'1x','1x','1x','1x'};
    checkGrid.BackgroundColor = [0.1 0.1 0.1];
    checkGrid.ColumnSpacing = 10;

    circle = uicheckbox(checkGrid,'Text','Circles');
    circle.Value = true;
    circle.FontColor = 'w';
    circle.FontName = 'Segoe UI';

    rectangle = uicheckbox(checkGrid,'Text','Rectangles');
    rectangle.Value = true;
    rectangle.FontColor = 'w';
    rectangle.FontName = 'Segoe UI';

    triangle = uicheckbox(checkGrid,'Text','Triangle');
    triangle.Value = true;
    triangle.FontColor = 'w';
    triangle.FontName = 'Segoe UI';

    pentagon = uicheckbox(checkGrid,'Text','Pentagon');
    pentagon.Value = true;
    pentagon.FontColor = 'w';
    pentagon.FontName = 'Segoe UI';

    reconstructButton.ButtonPushedFcn = @(src,event) processImage(ax1, ax2, percentSlider.Value, saveButton, circle, rectangle, triangle, pentagon);
end

function loadImage(ax)
    % Open file explorer to select image
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'});
    if file
        img = imread(fullfile(path, file));
        imshow(img, 'Parent', ax,'InitialMagnification','fit');
        axis(ax,'image');
    else
        disp('No image selected');
    end
end

function processImage(ax1, ax2, slider_value, saveButton, circle, rectangle, triangle, pentagon)
    % Get the image from ax1 (the original)
    img = getimage(ax1);

    edges = preprocessing(img);
    fourier_descriptors = fourier_transform(edges);
    rec_img = reconstruction(fourier_descriptors, slider_value);
    [centers, radii] = shape_descriptor(rec_img);

    % Show original image in ax2
    imshow(rec_img, 'Parent', ax2,'InitialMagnification','fit');
    axis(ax2,'image');
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
    
function updateSlider(value,sliderLabel)
    sliderLabel.Text = sprintf('%d%%',round(value));
end