function features = ComputeScaleFeatures(database, scalePercentage)
    img = reshape(database(1, :), 112, 92);
    scaledImage = imresize(img, scalePercentage/100);
    features = zeros(size(database, 1), size(scaledImage,1)*size(scaledImage,2));
    for i = 1:size(database, 1)
        img = reshape(database(i, :), 112, 92);
%         basePath = 'E:\Учеба\Биометрические_технологии\3\Faces';
%         folderPath = fullfile(basePath, ['s', num2str(7)]);
%         imagePath = fullfile(folderPath, ['6', '.pgm']);
%         folderPath = fullfile(basePath, ['s', num2str(1)]);
%         imagePath = fullfile(folderPath, ['1', '.pgm']);
%         img = imread(imagePath);
%         folderPath = fullfile(basePath, ['s', num2str(1)]);
%         imagePath = fullfile(folderPath, ['face', '.png']);
%         img = rgb2gray(imread(imagePath));
%         figure
%         imshow(img)

        scaledImage = imresize(img, scalePercentage/100);
        
%         figure
%         imshow(scaledImage,[])

        features(i, :) = scaledImage(:)';
    end
end