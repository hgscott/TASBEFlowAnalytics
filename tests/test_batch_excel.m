function test_suite = test_batch_excel
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_batch_excel_endtoend
    % Create TemplateExtraction object
    [filepath, ~, ~] = fileparts(mfilename('fullpath'));
    extractor = TemplateExtraction('test_templates/test_batch_template1.xlsx', [end_with_slash(filepath) '../']);
    CM = load_or_make_testing_colormodel();
    [results, statisticsFile, histogramFile] = batch_analysis_excel(extractor, CM);
    
    % Make sure statistics and histogram files are 'none'
    assertEqual(statisticsFile, 'none');
    assertEqual(histogramFile, 'none');
    
    % Yellow, Red, Blue
    result1_expected_bincounts = [...
             637          36       6806; % clipped by the drop threshold        
            2753        2706       8017;        
            3323        2637       8782;        
            4640        2623       8558;        
            4624        3739       7617;        
            5595        4714       6343;        
            5937        5304       3931;        
            6282        5434       1817;        
            5747        5801       511;        
            4272        4683       124;        
            3097        4012       0;
            2284        3469       0;
            2340        2917       0;
            2545        3200       0;
            2845        3612       0;
            3390        3985       0;
            3755        4034       0;
            4031        3985       0;
            4246        4135       0;
            4436        4179       0;
            4502        4199       0;
            4289        4095       0;
            4007        3890       0;
            3630        3817       0;
            3244        3685       0;
            2738        3509       0;
            2203        3248       0;
            1731        3032       0;
            1406        2598       0;
            989        2401        0;
            769        1920        0;
            493        1626        0;
            391        1353        0;
            214         995        0;
            150         808        0;
            101         634        0;
               0           428        0;
               0           272        0;
               0           176        0; 
               0           122        0; 
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               0           0           0;
               ];

    result_expected_means = [...
        260800	429100	22170
        260700	426500	22200
        269300	444900	22110
        271400	454400	22050
        262600	450600	22160
        260800	448200	22550
        266800	445000	22820
        268800	460800	25400
        253000	482200	37920
        242800	492200	48930
        220000	486300	69260
        182500	592500	109400
        160100	697900	159100
        146800	772000	194800
        ];

    result_expected_stds = [...
        6.702	7.942    1.600
        6.710	7.944    1.599
        6.746	8.014    1.603
        6.599	7.922    1.604
        6.641	8.080    1.643
        6.595	7.936    1.703
        6.613	8.106    1.992
        6.308	8.224    3.057
        6.028	8.242    3.688
        5.731	8.056    4.508
        5.163	8.538    5.283
        4.613	8.392    5.603
        4.301	8.263    5.578
        ];

    result_expected1_gmm_means = [...
        4.6200    4.6817    4.2543    
        5.9921    6.0832    4.2543    
        ];
    result_expected1_gmm_stds = [...
        0.0783    0.0900    0.0692    
        0.3112    0.5154    0.0692    
        ];
    result_expected1_gmm_weights = [...
        0.4195    0.3215    0.5000    
        0.5805    0.6785    0.5000    
        ];

    result_expected14_gmm_means = [...
        4.6252    4.7382    4.3427    
        5.5610    6.2619    5.6856    
        ];
    result_expected14_gmm_stds = [...
        0.0804    0.1034    0.0904    
        0.2650    0.5099    0.2825    
        ];
    result_expected14_gmm_weights = [...
        0.4211    0.2456    0.3486    
        0.5789    0.7544    0.6514    
        ];

    assertEqual(numel(results), 14);

    % spot-check name, bincenter, bin-count
    assertEqual(results{1}.condition, 'Dox 0.1');
    assertElementsAlmostEqual(log10(results{1}.bincenters([1 10 40 end])), [4.0500    4.9500    7.9500    9.9500], 'relative', 1e-2);
    assertElementsAlmostEqual(results{1}.bincounts, result1_expected_bincounts,     'relative', 1e-2, 50);

    assertEqual(results{14}.condition, 'Dox 2000');
    assertElementsAlmostEqual(log10(results{14}.bincenters([1 10 40 end])), [4.0500    4.9500    7.9500    9.9500], 'relative', 1e-2);

    for i=1:14
        assertElementsAlmostEqual(results{i}.means, result_expected_means(i,:), 'relative', 1e-2);
        assertElementsAlmostEqual(results{i}.stds,  result_expected_stds(i,:),  'relative', 1e-2);
    end

    assertElementsAlmostEqual(results{1}.gmm_means,  result_expected1_gmm_means,  'relative', 1e-2);
    assertElementsAlmostEqual(results{1}.gmm_stds,  result_expected1_gmm_stds,  'relative', 1e-2);
    assertElementsAlmostEqual(results{1}.gmm_weights,  result_expected1_gmm_weights,  'relative', 1e-2);
    assertElementsAlmostEqual(results{14}.gmm_means,  result_expected14_gmm_means,  'relative', 1e-2);
    assertElementsAlmostEqual(results{14}.gmm_stds,  result_expected14_gmm_stds,  'relative', 1e-2);
    assertElementsAlmostEqual(results{14}.gmm_weights,  result_expected14_gmm_weights,  'relative', 1e-2);
    