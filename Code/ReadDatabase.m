function [database, labels] = ReadDatabase(Fawkes)
    % Путь к базе данных
    basePath = 'E:\Учеба\Биометрические_технологии\3\Faces';
    folders = 1:40;
    imagesPerFolder = 10;
    
    % Размер изображений
    imageSize = [92, 112]; % Размер 92x112
    
    % Загрузка базы данных
    database = [];
    labels = [];
    for folder = folders
        folderPath = fullfile(basePath, ['s', num2str(folder)]);
        for imageIdx = 1:imagesPerFolder
            imagePath = fullfile(folderPath, [num2str(imageIdx), '_low_cloaked.png']);
            if(Fawkes == 1)
                img = rgb2gray(imread(imagePath));
            else
                img = imread(imagePath);
            end
            img = double(img); % Преобразуем в double для обработк
            database = [database; img(:)']; % Векторизация изображения
            labels = [labels; folder]; % Метки классов
        end
    end
    
    % Нормализация данных
    database = database / 255.0; % Преобразование яркости в диапазон [0, 1]
end
