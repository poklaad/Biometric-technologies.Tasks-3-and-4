function features = ComputeDFTFeatures(database, numComponents)
    features = zeros(size(database, 1), sum(1:numComponents));
    for i = 1:size(database, 1)
        img = reshape(database(i, :), 112, 92);

%         basePath = 'E:\Учеба\Биометрические_технологии\3\Faces';
%         folderPath = fullfile(basePath, ['s', num2str(1)]);
%         imagePath = fullfile(folderPath, ['1', '.pgm']);
%         img = imread(imagePath);
%         figure
%         imshow(img)

        % 2D DFT преобразование
        dftResult = fft2(double(img));
        dftResult = dftResult(1:numComponents, 1:numComponents);
        dftResult = abs(dftResult);

        q = 0;
        line=[];
        for k = 1:numComponents
            for j = k:-1:1
                q=q+1;
                line(q) = dftResult(k+1-j,j);
            end
        end
        features(i, :) = line(:)';
%         figure
%         imshow(dftResult, [])
%         colormap('gray'); % Цветовая карта - оттенки серого
    end
end