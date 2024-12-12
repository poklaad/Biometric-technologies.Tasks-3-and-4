function [trainData, trainLabels, testData, testLabels] = PrepareData(database, labels, numTrainPerClass)
    % database: матрица данных (NxD), где N - число изображений, D - размер признакового пространства
    % labels: вектор меток классов (Nx1)
    % numTrainPerClass: число элементов для обучения из каждого класса

    % Уникальные классы
    classes = unique(labels);
    numClasses = length(classes);

    % Инициализация выборок
    trainData = [];
    trainLabels = [];
    testData = [];
    testLabels = [];

    % Проход по каждому классу
    for i = 1:numClasses
        class = classes(i);
        
        % Извлечение индексов текущего класса
        classIndices = find(labels == class);
        numSamples = length(classIndices);
        classIndices = classIndices(randperm(numSamples));

        % Проверка, достаточно ли данных в классе
        if numSamples < numTrainPerClass
            error('Недостаточно данных в классе %d для выбора %d элементов.', class, numTrainPerClass);
        end

        % Разделение данных на тренировочную и тестовую выборки
        trainIndices = classIndices(1:numTrainPerClass); % Первые N элементов - обучающие
        testIndices = classIndices(numTrainPerClass+1:end); % Остальные - тестовые

        % Добавление данных в выборки
        trainData = [trainData; database(trainIndices, :)];
        trainLabels = [trainLabels; labels(trainIndices)];
        testData = [testData; database(testIndices, :)];
        testLabels = [testLabels; labels(testIndices)];
    end
end