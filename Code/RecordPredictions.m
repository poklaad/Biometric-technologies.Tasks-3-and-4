function RecordPredictions(testPredictedLabels, testLabels, testData, trainData, ...
    trainRatio, videoFilename, methodName, parametr)
    % testPredictedLabels: предсказанные классы изображений
    % testLabels: истинные классы изображений
    % testData: тестовые изображения
    % trainData: тренировочные изображения
    % trainRatio: количество тренировочных изображений на каждый класс
    % videoFilename: имя файла для сохранения видео
    
    % Параметры
    pauseDuration = 1; % Время задержки между кадрами (в секундах)
    numClasses = 40; % Общее количество классов

    % Количество тестовых изображений на класс
    numTestImagesPerClass = 10 - trainRatio;

    % Указание папки и имени файла
    % Временной штамп
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS'); % Текущая дата и время
    videoFilename = sprintf(videoFilename + "%s.avi", timestamp);
    
    % Создание объекта видеозаписи
    videoWriter = VideoWriter(videoFilename, 'Uncompressed AVI'); % Используем AVI
    videoWriter.FrameRate = 30; % Частота кадров
    open(videoWriter);

    % Создание фигуры
    predictionsFigure = figure;
    set(0, 'CurrentFigure', predictionsFigure); % Активируем окно

    % Настройка размера окна
    width = 1000; % Ширина окна
    height = 400; % Высота окна
    x = 100; % Координата X левого верхнего угла
    y = 100; % Координата Y левого верхнего угла
    set(predictionsFigure, 'Position', [x, y, width, height]);
    
    % Итерация по тестовым изображениям
    for i = 1:length(testLabels)
        % Получение истинного и предсказанного классов
        trueClass = testLabels(i);
        predictedClass = testPredictedLabels(i);

        % Вычисление индекса текущего тестового изображения
        classStartIdxInTest = (trueClass - 1) * numTestImagesPerClass + 1;
        testImageIdx = classStartIdxInTest + mod(i - 1, numTestImagesPerClass);

        % Получение эталонных изображений из trainData
        classStartIdxInTrain = (trueClass - 1) * trainRatio + 1;
        predictedClassStartIdxInTrain = (predictedClass - 1) * trainRatio + 1;

        trueReferenceImage = trainData(classStartIdxInTrain, :);
        predictedReferenceImage = trainData(predictedClassStartIdxInTrain, :);

        % Текущее тестовое изображение
        testImage = reshape(testData(testImageIdx, :), [112, 92]);

        % Реконструкция эталонных изображений
        trueReferenceImage = reshape(trueReferenceImage, [112, 92]);
        predictedReferenceImage = reshape(predictedReferenceImage, [112, 92]);

        % Визуализация
        clf; % Очистка фигуры
        subplot(1, 3, 1);
        imshow(testImage, []);
        title('Тестовое изображение');
        
        subplot(1, 3, 2);
        imshow(trueReferenceImage, []);
        title(['Истинный класс: ', num2str(trueClass)]);

        subplot(1, 3, 3);
        imshow(predictedReferenceImage, []);
        title(['Предсказанный класс: ', num2str(predictedClass)]);

        if (methodName ~= "")
            sgtitle(sprintf("Классификация тестовых изображений. Количество " + ...
                "тренировочных изображений: %d/10\nМетод: %s. Значение параметра: %s", ...
                trainRatio, methodName, num2str(parametr)));
        else
             sgtitle(sprintf("Классификация тестовых изображений. Количество " + ...
                "тренировочных изображений: %d/10", trainRatio));
        end


        % Добавление текущего кадра в видео
        frame = getframe(predictionsFigure);
        numPauseFrames = round(pauseDuration * videoWriter.FrameRate);
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
