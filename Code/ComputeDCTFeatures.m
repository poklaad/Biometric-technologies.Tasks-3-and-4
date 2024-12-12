function features = ComputeDCTFeatures(database, numComponents)
    features = zeros(size(database, 1), sum(1:numComponents));
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
        
        dct = dct2(img);
%         figure;
%         imshow(dct, []); % Показ матрицы с автоматическим масштабированием
%         colormap('gray'); % Цветовая карта - оттенки серого
        dct = dct(1:numComponents, 1:numComponents);
        q = 0;
        line=[];
        for k = 1:numComponents
            for j = k:-1:1
                q=q+1;
                line(q) = dct(k+1-j,j);
            end
        end
        features(i, :) = line(:)';
%         figure;
%         imshow(dct, []); % Показ матрицы с автоматическим масштабированием
%         colormap('gray'); % Цветовая карта - оттенки серого
    end
end