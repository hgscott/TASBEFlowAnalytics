function test_suite = test_batch_output_excel
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_batch_output_excel_endtoend
    % Create TemplateExtraction object
    extractor = TemplateExtraction('../test_templates/test_batch_template4.xlsx');
    [filepath, ~, ~] = fileparts(mfilename('fullpath'));
    CM = load_or_make_testing_colormodel();
    [results, statisticsFile, histogramFile] = batch_analysis_excel([end_with_slash(filepath) '../'], extractor, CM);
    
    % Read the files into matlab tables
    if (is_octave)
        statsTable = csv2cell(statisticsFile);
        histTable = csv2cell(histogramFile);
        statsCell = statsTable(2:end,:);
        histCell = histTable(2:end,:);
    else
        statsTable = readtable(statisticsFile);
        histTable = readtable(histogramFile);
        statsCell = table2cell(statsTable);
        histCell = table2cell(histTable);
    end

    % Split the stats table
    geoMeans = statsCell(:,5:7);
    geoStdDevs = statsCell(:,8:10);
    gmmMeans = statsCell(:,11:16);
    gmmStds = statsCell(:,17:22);
    gmmWeights = statsCell(:,23:28);


    % Split the hist table
    binCounts = histCell(:,3:5);

    % Strip out the padding put into the sampleIds, means, and stdDevs
    sampleIDListWithPadding = statsCell(:,1);
    sampleIDs = sampleIDListWithPadding(find(~cellfun(@isempty,sampleIDListWithPadding)));


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check results in CSV files:

    % The first five rows should be enough to verify writing the histogram file
    % correctly.
    expected_bincounts = [...
            2200        1383       6799;        
            2732        2696       8012;        
            3327        2638       8780;        
            4637        2632       8563;        
            4623        3741       7622;        
            ];

    % Means and stddevs tests writing the statistics file correctly.
    expected_means = 1e5 * [...
        2.4948    4.1064    0.2217    
        2.4891    4.0757    0.2219    
        2.5766    4.2599    0.2211    
        2.5874    4.3344    0.2205    
        2.5099    4.3095    0.2216    
        2.4862    4.2764    0.2255    
        2.5457    4.2586    0.2281    
        2.5739    4.4073    0.2539    
        2.4218    4.6213    0.3791    
        2.3266    4.7217    0.4891    
        2.1068    4.6593    0.6924    
        1.7513    5.6729    1.0930    
        1.5451    6.7144    1.5909    
        1.4175    7.4609    1.9472    
        ];

    expected_stds = [...
        6.7653    8.1000    1.6006    
        6.8670    8.1306    1.5990    
        6.8650    8.1230    1.5981    
        6.9155    8.2135    1.6036    
        6.7565    8.1069    1.6035    
        6.8020    8.2742    1.6427    
        6.7618    8.1220    1.7030    
        6.7701    8.2937    1.9914    
        6.4579    8.4052    3.0568    
        6.1704    8.4187    3.6868    
        5.8686    8.2393    4.5068    
        5.2780    8.7369    5.2819    
        4.7061    8.5892    5.6018    
        4.3900    8.4391    5.5773    
        ];

    expected_gmm_means = 10.^[...
        4.6200    5.9921    4.6817    6.0832   4.2543    4.2543;    % row 1
        ];

    expected_gmm_stds = 10.^[...
        0.0783    0.3112    0.0900    0.5154    0.0692    0.0692;     % row 1
        ];

    expected_gmm_weights = [...
        0.4195    0.5805    0.3215    0.6785    0.5000    0.5000;     % row 1
        ];

    assertEqual(numel(sampleIDs), 3);
    %assertEqual(numel(sampleIDs), 7);

    % spot-check names
    assertEqual(sampleIDs{1}, 'Dox 0.1/0.2');
    assertEqual(sampleIDs{3}, 'Dox 2.0/5.0');
    %assertEqual(sampleIDs{7}, 'Dox 1000.0/2000.0');

    % spot-check first five rows of binCounts
    assertElementsAlmostEqual(cell2mat(binCounts(1:5,:)), expected_bincounts, 'relative', 2e-2);

    % spot-check geo means and geo std devs.
    for i=1:6, % was 7
        assertElementsAlmostEqual(cell2mat(geoMeans(i,:)), expected_means(i,:), 'relative', 1e-2);
        assertElementsAlmostEqual(cell2mat(geoStdDevs(i,:)), expected_stds(i,:),  'relative', 1e-2);
    end

    % spot check Gaussian Mixture Model materials:
    assertElementsAlmostEqual(cell2mat(gmmMeans(1,:)), expected_gmm_means, 'relative', 1e-2);
    assertElementsAlmostEqual(cell2mat(gmmStds(1,:)), expected_gmm_stds, 'relative', 1e-2);
    assertElementsAlmostEqual(cell2mat(gmmWeights(1,:)), expected_gmm_weights, 'relative', 1e-2);
    
    % Check the first five rows of the first point cloud file
    expected_pointCloud = [...
        42801.34    40500.46    33567.67
        2456.10     42822.39    1039.11
        70903.34    68176.25    20623.25
        2830130.69  17561178.05   1039.11
        8742.07     2238.27     1039.11
        ];

    % The first point cloud file: /tmp/LacI-CAGop_B3_B03_P3_PointCloud.csv
    firstPointCloudFile = '/tmp/CSV/LacI-CAGop_B3_P3_PointCloud.csv';

    % Read the point cloud into matlab tables
    if (is_octave)
        cloudTable = csv2cell(firstPointCloudFile);
        cloudCell = cloudTable(2:end,:);
    else
      cloudTable = readtable(firstPointCloudFile);
      cloudCell = table2cell(cloudTable);
    end

    % Split the cloud table
    points = cloudCell(1:5,:);

    % spot-check first five rows of binCounts
    assertElementsAlmostEqual(cell2mat(points), expected_pointCloud, 'relative', 1e-2);
    
    