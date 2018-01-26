clear all
%this tests the hello mex function
hello([0 0; 0 0; 1 1; 0 1; 1 0; 0 1; 1 0; 1 1], [0 0; 0 1; 1 0; 1 1],exp(j*(pi/4+pi/2*[0;1;2;3])))