prompt = sprintf("Should we use Fawkes image?\nNo: 0\nYes: 1\n");
x = input(prompt);

% Загрузка и подготовка данных
[database, labels] = ReadDatabase(x);

% Различные алгоритмы извлечения признаков
methods = {
    'Histogram', @(data, bins) ComputeHistogramFeatures(data, bins);
    'DCT', @(data, numComponents) ComputeDCTFeatures(data, numComponents);
    'DFT', @(data, numComponents) ComputeDFTFeatures(data, numComponents);
    'Gradient', @(data, W) ComputeGradientFeatures(data, W);
    'Scale', @(data, scalePercentage) ComputeScaleFeatures(data, scalePercentage);
};

% Цикл по методам
for methodIdx = 1:size(methods, 1)
    methodName = methods{methodIdx, 1};
    featureExtractionFunc = methods{methodIdx, 2};

    resultGraphics = figure; % Создаём фигуру для всех графиков
    numPlots = 4; % Количество графиков (по числу trainRatio)
    legendEntries = {}; % Массив для хранения легенд
    colors = lines(2); % Генерация цветов для графиков
    
    %Разбиение данных на тестовый и тренировочный набор
    for trainRatio = 2:2:8 % Количество фотографий в каждом классе, используемые для обучения
        [trainData, trainLabels, testData, testLabels] = PrepareData(database, labels, trainRatio);
        
        % Различные параметры классификатора
        switch(methodName)
            case "Histogram"
                parametrs = 10:20:70;
            case "DCT"
                parametrs = 4:4:16;
            case "DFT"
                parametrs = 4:4:16;
            case "Gradient"
                parametrs = 2:3:11;
            case "Scale"
                parametrs = 5:25:80;
        end

        testAccuracies = zeros(size(parametrs));
        allAccuracies = zeros(size(parametrs));
        
        %Работа классификатора
        for i = 1:length(parametrs)
            % Получение признаков для выборок
            trainFeatures = featureExtractionFunc(trainData, parametrs(i));
            testFeatures = featureExtractionFunc(testData, parametrs(i));
        
            % Классификация на тестовой выборке
            testPredictedLabels = ClassifyByMinimumDistance(trainFeatures, trainLabels, testFeatures);
            testAccuracies(i) = mean(testPredictedLabels == testLabels);
        
            % Классификация на всей выборке
            allPredictedLabels = ClassifyByMinimumDistance(trainFeatures, trainLabels, [testFeatures; trainFeatures]);
            allAccuracies(i) = mean(allPredictedLabels == [testLabels; trainLabels]);

            if (trainRatio == 8 && i == ceil(length(parametrs)/2))

                featuresExtractionVideoFilename = methodName + "_features_extraction_record";
                RecordFeaturesExtraction(trainFeatures, trainData, trainRatio, ...
                    featuresExtractionVideoFilename, methodName, parametrs(i));

                predictionsVideoFilename = methodName + "_predictions_record";
                RecordPredictions(testPredictedLabels, testLabels, testData, ...
                    trainData, trainRatio, predictionsVideoFilename, methodName, parametrs(i));
    
            end
            stringToDisp = "trainRatio" + num2str(trainRatio) + "method" + methodName + "parametr i:" + num2str(i) + "/" + num2str(length(parametrs));
            disp(stringToDisp)
        end
        
        figure(resultGraphics);
        set(0, 'CurrentFigure', resultGraphics); % Активируем окно f1
        % Построение графиков в подграфике
        subplot(2, 2, trainRatio/2); % Организация в сетке 2x2
        hold on; % Удерживает текущий график для добавления новых кривых
        plot(parametrs, allAccuracies, '-o', 'Color', colors(1, :)); % Тестирование на всей выборке
        plot(parametrs, testAccuracies, '-s', 'Color', colors(2, :)); % Тестирование на тестовой выборке
        hold off;
        
        % Настройка осей и заголовка
        xlabel('Значение параметра');
        ylabel('Точность (%)');
        title("Train Ratio = " + num2str(trainRatio));
        grid on;
        ylim([0., 1.]);
        
        % Добавление описания для легенды
        if trainRatio == 2 % Добавляем в легенду только один раз
            legendEntries = {'Классификация на всем наборе данных', 'Классификация на тестовой выборки'};
        end

        stringToDisp = "trainRatio" + num2str(trainRatio) + "method" + methodName;
        disp(stringToDisp)
    
    end
    
    stringToDisp = "method" + methodName + "finished first part";
    disp(stringToDisp)
    
    figure(resultGraphics);
    % Добавление общей легенды
    legendHandle = legend(legendEntries, 'Orientation', 'horizontal');
    set(legendHandle, 'Position', [0.35, 0.01, 0.3, 0.05]); % Ручная настройка позиции легенды
    sgtitle("Сравнение точности классификации " + methodName + " для разных Train Ratios"); % Общий заголовок

    width = 800; % Ширина окна
    height = 800; % Высота окна
    x = 100; % Координата X левого верхнего угла
    y = 100; % Координата Y левого верхнего угла
    set(resultGraphics, 'Position', [x, y, width, height]);

    % Сохранение графика
    pictureName = methodName + "_classificaiton_comparison";
    pngPicureName = pictureName + ".png";
    saveas(resultGraphics, pngPicureName); % Сохранение в файл png
    figPicureName = pictureName + ".fig";
    saveas(resultGraphics, figPicureName); % Сохранение текущей фигуры в формате .fig
    
    % Диапазон значений числа блоков и параметра
    kValues = 4:4:16; % Число блоков для кросс-валидации
    
    % Инициализация для хранения средних точностей
    crossValidationAccuracies = zeros(length(kValues), length(parametrs));
    
    % Цикл по числу блоков
    for kIdx = 1:length(kValues)
        k = kValues(kIdx); % Текущее значение числа блоков
        cv = cvpartition(labels, 'KFold', k); % Создание объекта разбиения
    
        % Цикл по параметрам
        for parametrsIdx = 1:length(parametrs)
            testAccuracies = zeros(cv.NumTestSets, 1); % Точности для каждого блока
            
            % Кросс-валидация
            for fold = 1:cv.NumTestSets
                % Индексы обучающих и тестовых данных
                trainIdx = training(cv, fold);
                testIdx = test(cv, fold);
                
                % Разделение данных
                trainData = database(trainIdx, :);
                trainLabels = labels(trainIdx);
                testData = database(testIdx, :);
                testLabels = labels(testIdx);
                
                % Извлечение признаков
                trainFeatures = featureExtractionFunc(trainData, parametrs(parametrsIdx));
                testFeatures = featureExtractionFunc(testData, parametrs(parametrsIdx));

                
                % Классификация
                testPredictedLabels = ClassifyByMinimumDistance(trainFeatures, trainLabels, testFeatures);
                
                % Вычисление точности
                testAccuracies(fold) = mean(testPredictedLabels == testLabels) * 100;

                stringToDisp = "kIdx: " + num2str(kIdx) + "/" + num2str(length(kValues)) + "method" ...
                    + methodName + "parametrsIdx: " + num2str(parametrsIdx) + "/" ...
                    + num2str(length(parametrs)) + "fold: " + num2str(fold) + "/" + num2str(cv.NumTestSets);
                disp(stringToDisp)
            end
            
            % Сохранение средней точности для текущего числа блоков и
            % параметра
            crossValidationAccuracies(kIdx, parametrsIdx) = mean(testAccuracies);

            stringToDisp = "kIdx: " + num2str(kIdx) + "/" + num2str(length(kValues)) + "method" ...
                + methodName + "parametrsIdx: " + num2str(parametrsIdx) + "/" ...
                + num2str(length(parametrs));
            disp(stringToDisp)
        end
        crossValidationAccuracies(kIdx, parametrsIdx) = mean(testAccuracies);

        stringToDisp = "kIdx: " + num2str(kIdx) + "/" + num2str(length(kValues)) + "method" + methodName;
        disp(stringToDisp)
    end
    
    % Построение графика
    crossvalidationGraphic = figure;
    hold on;
    
    % Цветовая схема для графиков
    colors = lines(length(kValues));
    
    for kIdx = 1:length(kValues)
        plot(parametrs, crossValidationAccuracies(kIdx, :), '-o', 'DisplayName', ['Количество блоков = ', num2str(kValues(kIdx))], 'Color', colors(kIdx, :));
    end
    
    % Настройка графика
    xlabel('Значение параметра');
    ylabel('Точность (%)');
    title("Зависимость точности " + methodName + " от числа блоков и значений параметра");
    legend('show'); % Общая легенда
    grid on;
    hold off;

    width = 800; % Ширина окна
    height = 800; % Высота окна
    x = 100; % Координата X левого верхнего угла
    y = 100; % Координата Y левого верхнего угла
    set(crossvalidationGraphic, 'Position', [x, y, width, height]);

    % Сохранение графика
    pictureName = methodName + "_crossvalidation";
    pngPicureName = pictureName + ".png";
    saveas(crossvalidationGraphic, pngPicureName); % Сохранение в файл png
    figPicureName = pictureName + ".fig";
    saveas(crossvalidationGraphic, figPicureName); % Сохранение текущей фигуры в формате .fig

    stringToDisp = "method" + methodName + "finished second part";
    disp(stringToDisp)
end
