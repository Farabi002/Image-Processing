% Read the image
img = imread('C:\Users\farab\Desktop\Thesis\fitzpatrick17k\data\finalfitz17k\00d5f0c643a2c4317c33bcfcc7b56759.jpg');

% Convert the image to grayscale if it is not already
if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

% Plot the histogram
figure;
imhist(img_gray);
title('Histogram of the Image');
xlabel('Pixel Intensity');
ylabel('Frequency');

%%

% Read the image
img = imread('C:\Users\farab\Desktop\Thesis\fitzpatrick17k\data\finalfitz17k\00c6529c53944cfc7b184abce798e16a.jpg');


% Display the image
figure;
imshow(img);
title('Image with Pixel Intensity Values');

% Enable pixel information display
impixelinfo;


%% flash corrrection (#1 trial)

function detect_skin_with_flash_correction(image_path)
    % Read the image
    image = imread(image_path);
    
    % Normalize lighting conditions using histogram equalization
    image_eq = histeq(rgb2gray(image));  % Apply histogram equalization on the grayscale version
    image_eq = imadjust(image_eq);       % Adjust the image intensity
    
    % Convert the image from RGB to HSV
    hsv_image = rgb2hsv(image);
    
    % Define HSV thresholds to detect skin tones
    lower_hsv_skin = [0, 0.12, 0.24];  % Lower bound for skin detection
    upper_hsv_skin = [0.12, 1, 1];     % Upper bound for skin detection

    % Handle reflections: Define a separate HSV range for bright/overexposed regions
    lower_hsv_reflection = [0, 0, 0.9];  % Lower bound for very bright regions
    upper_hsv_reflection = [1, 0.5, 1];  % Upper bound for bright regions due to reflection
    
    % Create a mask for normal skin regions
    skin_mask = (hsv_image(:,:,1) >= lower_hsv_skin(1)) & (hsv_image(:,:,1) <= upper_hsv_skin(1)) & ...
                (hsv_image(:,:,2) >= lower_hsv_skin(2)) & (hsv_image(:,:,2) <= upper_hsv_skin(2)) & ...
                (hsv_image(:,:,3) >= lower_hsv_skin(3)) & (hsv_image(:,:,3) <= upper_hsv_skin(3));
            
    % Create a separate mask for overexposed (reflection) regions
    reflection_mask = (hsv_image(:,:,1) >= lower_hsv_reflection(1)) & (hsv_image(:,:,1) <= upper_hsv_reflection(1)) & ...
                      (hsv_image(:,:,2) >= lower_hsv_reflection(2)) & (hsv_image(:,:,2) <= upper_hsv_reflection(2)) & ...
                      (hsv_image(:,:,3) >= lower_hsv_reflection(3)) & (hsv_image(:,:,3) <= upper_hsv_reflection(3));
                  
    % Combine both masks (normal skin + reflections)
    combined_mask = skin_mask | reflection_mask;
    
    % Perform morphological operations to smooth the mask and fill small holes
    combined_mask = imfill(combined_mask, 'holes');     % Fill holes in the detected skin areas
    combined_mask = imerode(combined_mask, strel('disk', 1)); % Erode to remove noise

    % Apply the mask to the original image
    skin_detected = bsxfun(@times, image, cast(combined_mask, 'like', image));
    
    % Display the original image and the skin detection result
    figure;
    subplot(1, 2, 1);
    imshow(image);
    title('Original Image');
    
    subplot(1, 2, 2);
    imshow(skin_detected);
    title('Skin Detected (With Flash Correction)');
end

% Example usage
image_path = 'C:\Users\farab\Desktop\Thesis\fitzpatrick17k\data\finalfitz17k\0ef52360bce4b5cd6e44eab70175d53c.jpg';  % Replace with the correct path to your image
detect_skin_with_flash_correction(image_path);



%% flash corrrection (#2 trial) ----Final

function detect_skin_with_flash_removal(image_path)
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
    
    % Display the original and the skin detection result
    figure;
    subplot(1, 2, 1);
    imshow(image);
    title('Original Image');

    subplot(1, 2, 2);
    imshow(skin_detected);
    title('Skin Detected (After Flash Removal)');
end

% Example usage
image_path = 'C:\Users\farab\Desktop\Thesis\fitzpatrick17k\data\finalfitz17k\18b400cdcc0cdfca79b397adbe8ffc74.jpg';  % Replace with the correct path to your image
detect_skin_with_flash_removal(image_path); 
