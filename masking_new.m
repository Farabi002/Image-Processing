





function [masked_image]= masking_new(image)
% Read the original RGB image
originalRGB = image;

% Convert the image to grayscale if it's a color image
if size(originalRGB, 3) == 3
    originalGray = rgb2gray(originalRGB);
else
    originalGray = originalRGB; % If it's already grayscale
end

% Compute the histogram
histogramValues = imhist(originalGray);

% Find the intensity with the highest number of pixels
[maxCount, intensity] = max(histogramValues);

% Define the range around the peak intensity
range = 25;
lowerThreshold = max(1, intensity - range);
upperThreshold = min(255, intensity + range);

% Create a binary mask using the intensity range
mask = (originalGray >= lowerThreshold) & (originalGray <= upperThreshold);

% Use the mask to preserve the original color information
resultImage = originalRGB;
resultImage(repmat(~mask, [1 1 3])) = 0;

% Display the original and result images side by side

masked_image = resultImage;

end







    





