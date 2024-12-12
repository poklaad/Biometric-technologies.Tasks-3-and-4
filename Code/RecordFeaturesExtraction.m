function RecordFeaturesExtraction(trainFeatures, trainData, trainRatio, ...
    videoFilename, methodName, parametr)

    % trainFeatures: признаки тренировочных изображений
    % trainData: тренировочные изображения
    % trainRatio: количество тренировочных изображений на каждый класс
    % videoFilename: имя файла для сохранения видео
    
    % Параметры
    pauseDuration = 1; % Время задержки между кадрами (в секундах)
    numClasses = 40; % Общее количество классов

    % Количество тестовых изображений на класс
    numTrainImagesPerClass = trainRatio;

    % Указание папки и имени файла
    % Временной штамп
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS'); % Текущая дата и время
    videoFilename = sprintf(videoFilename + "%s.avi", timestamp);
    
    % Создание объекта видеозаписи
    videoWriter = VideoWriter(videoFilename, 'Uncompressed AVI'); % Используем AVI
    videoWriter.FrameRate = 30; % Частота кадров
    open(videoWriter);

    % Создание фигуры
    featuresExtractionFigure = figure;
    set(0, 'CurrentFigure', featuresExtractionFigure); % Активируем окно

    % Настройка размера окна
    width = 800; % Ширина окна
    height = 400; % Высота окна
    x = 100; % Координата X левого верхнего угла
    y = 100; % Координата Y левого верхнего угла
    set(featuresExtractionFigure, 'Position', [x, y, width, height]);
    
    % Итерация по тестовым изображениям
    for i = 1:trainRatio:size(trainData,1)

        trainImage = trainData(i, :);
        trainFeature = trainFeatures(i, :);

        % Реконструкция эталонных изображений
        trainImage = reshape(trainImage, [112, 92]);

        % Визуализация
        clf; % Очистка фигуры
        subplot(1, 2, 1);
        imshow(trainImage, []);
        title('Тренировочное изображение');
        
        subplot(1, 2, 2);
        switch(methodName)
            case "Histogram"
                bar(trainFeature);
                xlabel('Бины');
                ylabel('Количество пикселей');
                title('Гистограмма изображения');
                grid on;
            case "DCT"
                featureToShow = zeros(parametr);
                q=0;
                for k = 1:parametr
                    for j = k:-1:1
                        q=q+1;
                        featureToShow(k+1-j,j) = trainFeature(q);
                    end
                end
                imshow(featureToShow, []);
            case "DFT"
                featureToShow = zeros(parametr);
                q=0;
                for k = 1:parametr
                    for j = k:-1:1
                        q=q+1;
                        featureToShow(k+1-j,j) = trainFeature(q);
                    end
                end
                imshow(featureToShow, []);
            case "Gradient"
                plot(trainFeature);
            case "Scale"
                img = reshape(trainData(1, :), 112, 92);
                scaledImage = imresize(img, parametr/100);
                trainFeature = reshape(trainFeature, [size(scaledImage,1), size(scaledImage,2)]);
                imshow(trainFeature, []);
        end
        title('Значение признака');

        sgtitle(sprintf("Извлечение признаков тренировочных изображений. " + ...
            "\nМетод: %s. Значение параметра: %s", ...
            methodName, num2str(parametr)));


        % Добавление текущего кадра в видео
        frame = getframe(featuresExtractionFigure);
        numPauseFrames = round(pauseDuration * videoWriter.FrameRate);
        writeVideo(videoWriter, frame);
        for j = 1:numPauseFrames
            writeVideo(videoWriter, frame); % Повторное добавление текущего кадра
        end

        % Пауза для просмотра
        %pause(pauseDuration);
    end

    % Закрытие объекта видеозаписи
    close(videoWriter);

    disp(['Видео сохранено в файл: ', videoFilename]);
end
