function predictedLabels = ClassifyByMinimumDistance(trainData, trainLabels, testData)
    predictedLabels = zeros(size(testData, 1), 1);
    for i = 1:size(testData, 1)
        distances = vecnorm(trainData - testData(i, :), 2, 2); % Евклидово расстояние
        [~, minIdx] = min(distances);
        predictedLabels(i) = trainLabels(minIdx);
    end
end