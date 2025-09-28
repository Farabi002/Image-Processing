function process_images_in_folder(input_folder, output_folder)
    % Get a list of all JPEG files in the input folder
    image_files = dir(fullfile(input_folder, '*.jpg'));
    
    % Check if output folder exists, create if it does not
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Initialize a progress bar
    total_images = length(image_files);
    h = waitbar(0, 'Processing images...');

    % Process each image file
    for i = 1:total_images
        % Construct the full file path
        image_path = fullfile(input_folder, image_files(i).name);
        
        % Read the input image
        image = imread(image_path);

        % Remove the flash effect using white balance adjustment
        % Convert to double for processing
        image_double = im2double(image);

        % Estimate the white point by averaging the highest RGB values
        max_rgb = max(image_double, [], [1, 2]);
        white_point = mean(max_rgb);

        % Apply white balance adjustment
        adjusted_image = image_double .* (white_point ./ max_rgb);

        % Clip the values to be in the valid range [0, 1]
        adjusted_image = min(max(adjusted_image, 0), 1);
        
        % Convert the adjusted image back to uint8 format
        adjusted_image = im2uint8(adjusted_image);

        % Convert the image from RGB to HSV
        hsv_image = rgb2hsv(adjusted_image);

        % Define lower and upper HSV values for skin tone detection
        lower = [0, 10/255, 90/255];  % Normalizing the values to [0,1]
        upper = [35/255, 255/255, 255/255];

        % Create a mask for skin detection
        skin_mask = (hsv_image(:,:,1) >= lower(1)) & (hsv_image(:,:,1) <= upper(1)) & ...
                    (hsv_image(:,:,2) >= lower(2)) & (hsv_image(:,:,2) <= upper(2)) & ...
                    (hsv_image(:,:,3) >= lower(3)) & (hsv_image(:,:,3) <= upper(3));
        
        % Perform morphological operations to smooth the mask
        skin_mask = imfill(skin_mask, 'holes');     % Fill holes in the detected skin areas
        skin_mask = imerode(skin_mask, strel('disk', 1)); % Erode to remove noise

        % Apply the mask to the adjusted image
        skin_detected = bsxfun(@times, adjusted_image, cast(skin_mask, 'like', adjusted_image));

        % Save the processed image to the output folder
        output_image_path = fullfile(output_folder, image_files(i).name);
        imwrite(skin_detected, output_image_path);

        % Update the progress bar
        waitbar(i / total_images, h, sprintf('Processing image %d of %d...', i, total_images));
    end

    % Close the progress bar when done
    close(h);
end

% Example usage
input_folder = 'C:\Users\farab\Desktop\Thesis\fitzpatrick17k\data\finalfitz17k';  % Input folder containing images
output_folder = 'C:\Users\farab\Desktop\Thesis\fitzpatrick17k\data\background removed by matlab';  % Output folder to save processed images
process_images_in_folder(input_folder, output_folder);
