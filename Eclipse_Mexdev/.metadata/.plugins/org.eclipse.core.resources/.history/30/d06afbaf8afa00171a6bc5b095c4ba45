#include <stdio.h>
#include <stdlib.h>
#include "mex.h"

/* computational subroutine */
void printer( double *xr, double *xi, size_t nx,
              double *yr, double *yi, size_t ny)
{
    mwSize i,j;

    /* perform the convolution of the complex vectors */
    for(i=0; i<nx; i++) {
        for(j=0; j<ny; j++) {
            printf("X Real is %f \n", *(xr+i));
            printf("X Imag is is %f \n", *(xi+i));
            printf("Y Real is %f \n", *(yr+j));
            printf("Y Imag is is %f \n", *(yi+j));
        }
    }
}

/* The gateway routine. */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double  *xr, *xi, *yr, *yi;
    size_t rows, cols;
    size_t nx, ny;

    /* get the length of each input vector */
    nx = 10;
    ny = 10;

    /* create a new array and set the output pointer to it */
    cols = nx + ny - 1;

    mwSize n = 0;
    for(n = 0; n < 10; n++)
    {
    	xr[n] = n;
    	xi[n] = -n;
    	yr[n] = n*2;
    	yi[n] = -n*2;
    }

    /* call the C subroutine */
    printer(xr, xi, nx, yr, yi, ny);

    return;
}
