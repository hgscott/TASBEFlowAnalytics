function test_suite = test_gmdistribution
    enter_test_mode();
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_simple_fit

mu = eye(2);
Sigma = eye(2);
GM = gmdistribution (mu, Sigma);
density = pdf(GM, [0 0; 1 1]);
assertElementsAlmostEqual (density(1) - density(2), 0, 1e-6);

[idx, nlogl, P, logpdf,M] = cluster (GM, eye(2));
assertEqual (idx, [1; 2]);
[idx2,nlogl2,P2,logpdf2] = cluster (GM, eye(2));
assertElementsAlmostEqual (nlogl - nlogl2, 0, 1e-6);
[idx3,nlogl3,P3] = cluster (GM, eye(2));
assertElementsAlmostEqual (P - P3, zeros (2), 1e-6);
[idx4,nlogl4] = cluster (GM, eye(2));
assertEqual (size (nlogl4), [1 1]);
idx5 = cluster (GM, eye(2));
assertEqual (idx - idx5, zeros (2,1));

D = mahal(GM, [1;0]);
assertElementsAlmostEqual (D - M(1,:), zeros (1,2), 1e-6);

P = posterior(GM, [0 1]);
assertElementsAlmostEqual (P - P2(2,:), zeros (1,2), 1e-6);

R = random(GM, 20);
assertEqual (size(R), [20, 2]);

