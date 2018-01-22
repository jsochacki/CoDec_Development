#include <stdio.h>
#include <stdlib.h>
#include "mex.h"

void print_real_matrix(double *matrix, mwSize M, mwSize N);
void print_complex_matrix(double *real_matrix,
                          double *imaginary_matrix,
                          mwSize M, mwSize N);

void print_real_matrix_test(double *matrix, mwSize M, mwSize N);

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

    double *binary_word_stream;
    double *binary_alphabet;
    double *complex_alphabet_real, *complex_alphabet_imaginary;
    double *output_real, *output_imaginary;

    mwSize binary_word_stream_M, binary_word_stream_N;
    mwSize binary_alphabet_M, binary_alphabet_N;
    mwSize complex_alphabet_M, complex_alphabet_N;
    mwSize output_M, output_N;

    binary_word_stream_M = mxGetM(prhs[0]);
    binary_word_stream_N = mxGetN(prhs[0]);
    binary_alphabet_M = mxGetM(prhs[1]);
    binary_alphabet_N = mxGetN(prhs[1]);
    complex_alphabet_M = mxGetM(prhs[2]);
    complex_alphabet_N = mxGetN(prhs[2]);

    binary_word_stream = mxGetPr(prhs[0]);
    binary_alphabet = mxGetPr(prhs[1]);
    complex_alphabet_real = mxGetPr(prhs[2]);
    complex_alphabet_imaginary = mxGetPi(prhs[2]);

/*    print_real_matrix_test(binary_word_stream,
                          binary_word_stream_M,
                          binary_word_stream_N);*/

    print_real_matrix(binary_word_stream,
                      binary_word_stream_M,
                      binary_word_stream_N);
    print_real_matrix(binary_alphabet,
                      binary_alphabet_M,
                      binary_alphabet_N);
    print_complex_matrix(complex_alphabet_real,
                         complex_alphabet_imaginary,
                         complex_alphabet_M,
                         complex_alphabet_N);

    // Set up the output stuff
    nlhs = 1;
    // We transpose during processing for minimum loop count due to the way
    // that matlab stores arrays in C
    output_M = 1; // Hard coded in this case as I have a very specific application
    output_N = binary_word_stream_M;
    // create output matrix "output"
    plhs[0] = mxCreateDoubleMatrix(output_M, output_N, mxCOMPLEX);
    output_real = mxGetPr(plhs[0]);
    output_imaginary = mxGetPi(plhs[0]);

    print_complex_matrix(output_real,
                         output_imaginary,
                         output_M,
                         output_N);

}

void print_real_matrix(double *matrix, mwSize M, mwSize N)
{
    mwIndex n = 0;
    mwIndex m = 0;

    for(m = 0; m < M; m++)
    {
        printf("[ ");
        for(n = 0; n < N; n++)
        {
            printf("%f ", matrix[m + (n * M)]);
            //printf("m=%d n=%d\n", m ,n);
        }
        printf("]\n");
    }
}

void print_complex_matrix(double *real_matrix,
                          double *imaginary_matrix,
                          mwSize M, mwSize N)
{
    mwIndex n = 0;
    mwIndex m = 0;

    for(m = 0; m < M; m++)
    {
        printf("[ ");
        for(n = 0; n < N; n++)
        {
            printf("%f+%fi ",
                   real_matrix[m + (n * M)],
                    imaginary_matrix[m + (n * M)]);
            //printf("m=%d n=%d\n", m ,n);
        }
        printf("]\n");
    }
}

void print_real_matrix_test(double *matrix, mwSize M, mwSize N)
{
    mwIndex n = 0;
    mwIndex m = 0;

    for(n = 0; n < N; n++)
    {
        printf("[ ");
        for(m = 0; m < M; m++)
        {
            printf("%f ", matrix[m + (n * M)]);
            //printf("m=%d n=%d\n", m ,n);
        }
        printf("]\n");
    }
}

void map_2_columns_to_1(double *data_matrix,
                        double *from_matrix,
                        double *to_real_matrix,
                        double *to_imaginary_matrix,
                        mwSize M)
{
    mwIndex m = 0;
    mwIndex N = 2;

    for(m = 0; m < M; m++)
    {
        data_matrix[m + (n * M)];
    }
}