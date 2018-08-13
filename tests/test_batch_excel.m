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
            2178        1373       6806;        
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

    result_expected_means = 1e5 * [...
        2.4796      4.0832      0.2213      
        2.4605      4.0592      0.2217      
        2.5462      4.2334      0.2201      
        2.5524      4.2831      0.2192      
        2.4833      4.2658      0.2202      
        2.4613      4.2593      0.2230      
        2.5221      4.2116      0.2246      
        2.5455      4.3739      0.2488      
        2.3947      4.5774      0.3723      
        2.2973      4.6921      0.4764      
        2.0812      4.6243      0.6808      
        1.7335      5.6471      1.0768      
        1.5283      6.6706      1.5798      
        1.4045      7.4507      1.9350      
        ];

    result_expected_stds = [...
        6.7127      8.0237      1.5964        
        6.7718      8.0481      1.5955      
        6.7734      8.0462      1.5855      
        6.8054      8.0832      1.5881      
        6.6713      7.9815      1.5876      
        6.7166      8.1935      1.6027      
        6.6764      7.9794      1.6348      
        6.6863      8.2016      1.8831      
        6.3741      8.2915      2.9448      
        6.0771      8.3279      3.5238      
        5.7805      8.1472      4.3923      
        5.2045      8.6548      5.1748      
        4.6337      8.5021      5.5516      
        4.3324      8.3937      5.5331      
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
    assertElementsAlmostEqual(results{1}.bincounts, result1_expected_bincounts,     'relative', 1e-2);

    assertEqual(results{14}.condition, 'Dox 2000');
    assertElementsAlmostEqual(log10(results{14}.bincenters([1 10 40 end])), [4.0500    4.9500    7.9500    9.9500], 'relative', 1e-2);

    for i=1:14,
        assertElementsAlmostEqual(results{i}.means, result_expected_means(i,:), 'relative', 1e-2);
        assertElementsAlmostEqual(results{i}.stds,  result_expected_stds(i,:),  'relative', 1e-2);
    end

    assertElementsAlmostEqual(results{1}.gmm_means,  result_expected1_gmm_means,  'relative', 1e-2);
    assertElementsAlmostEqual(results{1}.gmm_stds,  result_expected1_gmm_stds,  'relative', 1e-2);
    assertElementsAlmostEqual(results{1}.gmm_weights,  result_expected1_gmm_weights,  'relative', 1e-2);
    assertElementsAlmostEqual(results{14}.gmm_means,  result_expected14_gmm_means,  'relative', 1e-2);
    assertElementsAlmostEqual(results{14}.gmm_stds,  result_expected14_gmm_stds,  'relative', 1e-2);
    assertElementsAlmostEqual(results{14}.gmm_weights,  result_expected14_gmm_weights,  'relative', 1e-2);
    