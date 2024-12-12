function features = ComputeHistogramFeatures(database, bins)
    features = zeros(size(database, 1), bins);
    for i = 1:size(database, 1)
        img = reshape(database(i, :), 112, 92);
        features(i, :) = histcounts(img, bins, 'Normalization', 'probability');
    end
end