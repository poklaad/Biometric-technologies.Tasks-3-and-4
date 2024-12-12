% Загрузка и подготовка данных
[database, labels] = ReadDatabase();

% Различные алгоритмы извлечения признаков
methods = {
    'Histogram', @(data, bins) ComputeHistogramFeatures(data, bins);
    'DCT', @(data, numComponents) ComputeDCTFeatures(data, numComponents);
    'DFT', @(data, numComponents) ComputeDFTFeatures(data, numComponents);
    'Gradient', @(data, W) ComputeGradientFeatures(data, W);
    'Scale', @(data, scalePercentage) ComputeScaleFeatures(data, scalePercentage);
};

trainRatios = 2:2:8;
testAccuraciesAllMethods = zeros(size(methods, 1), length(trainRatios));
testAccuraciesParallel = zeros(length(trainRatios), 1);

for trainRatio = trainRatios % Процент выборки, используемый для обучения
    %Разбиение данных на тестовый и тренировочный набор
    [trainData, trainLabels, testData, testLabels] = PrepareData(database, labels, trainRatio);
    predictedLabelsAllMethods = zeros(size(methods, 1), size(testData,1));
    
    % Цикл по методам
    for methodIdx = 1:size(methods, 1)
        methodName = methods{methodIdx, 1};
        featureExtractionFunc = methods{methodIdx, 2};
        
        % Различные параметры классификатора
        switch(methodName)
            case "Histogram"
                parametr = 50;
            case "DCT"
                parametr = 8;
            case "DFT"
                parametr = 16;
            case "Gradient"
                parametr = 8;
            case "Scale"
                parametr = 30;
        end
        
        %Работа классификатора
        % Получение признаков для выборок
        trainFeatures = featureExtractionFunc(trainData, parametr);
        testFeatures = featureExtractionFunc(testData, parametr);
    
        % Классификация на тестовой выборке
        testPredictedLabelsOneMethod = ClassifyByMinimumDistance(trainFeatures, trainLabels, testFeatures);

        testAccuraciesAllMethods(methodIdx, trainRatio/2) = mean(testPredictedLabelsOneMethod == testLabels);
        predictedLabelsAllMethods(methodIdx, :) = testPredictedLabelsOneMethod;

        if (trainRatio == 8)
            featuresExtractionVideoFilename = "Parallel" + methodName + "_features_extraction_record";
            RecordFeaturesExtraction(trainFeatures, trainData, trainRatio, ...
                featuresExtractionVideoFilename, methodName, parametr);
        end
    end
    
    % Инициализация переменной для итоговых меток
    finalPredictedLabels = zeros(size(predictedLabelsAllMethods, 2),1);
    
    % Итерация по всем изображениям
    for i = 1:size(predictedLabelsAllMethods, 2)
        % Получаем метки, предсказанные всеми методами для текущего изображения
        currentPredictions = predictedLabelsAllMethods(:, i);
        
        % Подсчёт голосов за каждый класс
        uniqueClasses = unique(currentPredictions);
        votes = zeros(size(uniqueClasses));
        for j = 1:length(uniqueClasses)
            votes(j) = sum(currentPredictions == uniqueClasses(j));
        end
        
        % Определение класса с наибольшим количеством голосов
        [~, maxIdx] = max(votes);
        finalPredictedLabels(i) = uniqueClasses(maxIdx);
    end
    if (trainRatio == 8)
        predictionsVideoFilename = "Parallel_predictions_record";
        RecordPredictions(finalPredictedLabels, testLabels, testData, ...
            trainData, trainRatio, predictionsVideoFilename, "", "");
    end

    testAccuraciesParallel(trainRatio/2) = mean(finalPredictedLabels == testLabels);
end

figure
hold on
plot(trainRatios, testAccuraciesParallel, '-o'); % Параллельное предсказание
plot(trainRatios, testAccuraciesAllMethods');
hold off;

% Настройка осей и заголовка
xlabel('Количество изображений в тренировочной выборке от каждого класса');
ylabel('Точность (%)');
title("Точность параллельной системы");
grid on;
ylim([0., 1.]);

width = 1200; % Ширина окна
height = 600; % Высота окна
x = 100; % Координата X левого верхнего угла
y = 100; % Координата Y левого верхнего угла
set(gcf, 'Position', [x, y, width, height]);

% Добавление описания для легенды
legendEntries = {'Параллельная классификация', 'Классификация Histogram', 'Классификация DCT', ...
    'Классификация DFT', 'Классификация Gradient', 'Классификация Scale'};

% Добавление общей легенды
legendHandle = legend(legendEntries, 'Orientation', 'horizontal');
set(legendHandle, 'Position', [0.35, 0.01, 0.3, 0.05]); % Ручная настройка позиции легенды

% Сохранение графика
pictureName = "Parallel_classificaiton";
pngPicureName = pictureName + ".png";
saveas(gcf, pngPicureName); % Сохранение в файл png
figPicureName = pictureName + ".fig";
saveas(gcf, figPicureName); % Сохранение текущей фигуры в формате .fig
