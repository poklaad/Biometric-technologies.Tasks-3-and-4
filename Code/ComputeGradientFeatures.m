% W: ширина полосы
function features = ComputeGradientFeatures(database, W)
    features = zeros(size(database, 1), 112 - 2 * W);
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

        % Размеры изображения
        [rows, cols] = size(img);
    
        % Проверка корректности входных данных
        if W > rows / 2
            error('Ширина полосы W слишком велика для данного изображения.');
        end
    
        % Инициализация вектора признаков
        numSteps = rows - 2 * W;
        featureVector = zeros(1, numSteps);
    
        % Скользящее окно
        for step = 1:numSteps
            % Определение позиции полос
            topStart = step;
            topEnd = topStart + W;
            bottomStart = topStart + W;
            bottomEnd = bottomStart + W;
    
            % Извлечение полос
            topStrip = img(topStart:topEnd, :);
            bottomStrip = img(bottomStart:bottomEnd, :);
    
            % Вычисление градиента с использованием L2 нормы
            gradient = sqrt(sum((mean(topStrip, 1) - mean(bottomStrip, 1)).^2));
    
            % Сохранение среднего градиента как признака
            featureVector(step) = mean(gradient);
        end
%         figure
%         plot(featureVector)
        features(i, :) = featureVector(:)';
    end
end