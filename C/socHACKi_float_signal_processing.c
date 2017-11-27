
#include <stdlib.h>  // For malloc, calloc, realloc, etc...
#include "socHACKi_types.h" // For UINT, etc...

/******************************************************************************/
// initialize_ramp
/******************************************************************************/

// int
void initialize_ramp_int(int *x, UINT length_x)
{
    // Ramp initialize
    UINT i = 0;
    for ( ; i < length_x; i++)
    {
        x[i] = i;
    }
}

// short
void initialize_ramp_short(short *x, UINT length_x)
{
    // Ramp initialize
    UINT i = 0;
    for ( ; i < length_x; i++)
    {
        x[i] = i;
    }
}

// long
void initialize_ramp_long(long *x, UINT length_x)
{
    // Ramp initialize
    UINT i = 0;
    for ( ; i < length_x; i++)
    {
        x[i] = i;
    }
}

// float
void initialize_ramp_float(float *x, UINT length_x)
{
    // Ramp initialize
    UINT i = 0;
    for ( ; i < length_x; i++)
    {
        x[i] = i;
    }
}

// double
void initialize_ramp_double(double *x, UINT length_x)
{
    // Ramp initialize
    UINT i = 0;
    for ( ; i < length_x; i++)
    {
        x[i] = i;
    }
}

/******************************************************************************/
// swap_vectors
/******************************************************************************/

// int
void swap_vectors_int(int **x, UINT *length_x, int **y, UINT *length_y)
{
    UINT local_length_x = *length_x;
    UINT local_length_y = *length_y;

    // Swap lengths for the user
    swap_uint(length_x, length_y);

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        int *z = (int *) malloc(local_length_y * sizeof(int));

        UINT i = 0;
        for( ; i < local_length_y; i++)
        {
            z[i] = y[0][i];
        }

        // Transfer x to y
        *y = (int *) realloc(*y, local_length_x * sizeof(int));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = x[0][i];
        }

        // Transfer z to x
        *x = (int *) realloc(*x, local_length_y * sizeof(int));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = z[i];
        }

        free(z);
    }
    else
    {
        // Transfer x to z
        int *z = (int *) malloc(local_length_x * sizeof(int));

        UINT i = 0;
        for( ; i < local_length_x; i++)
        {
            z[i] = x[0][i];
        }

        // Transfer y to x
        *x = (int *) realloc(*x, local_length_y * sizeof(int));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = y[0][i];
        }

        // Transfer z to y
        *y = (int *) realloc(*y, local_length_x * sizeof(int));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = z[i];
        }

        free(z);
    }
}

// short
void swap_vectors_short(short **x, UINT *length_x, short **y, UINT *length_y)
{
    UINT local_length_x = *length_x;
    UINT local_length_y = *length_y;

    // Swap lengths for the user
    swap_uint(length_x, length_y);

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        short *z = (short *) malloc(local_length_y * sizeof(short));

        UINT i = 0;
        for( ; i < local_length_y; i++)
        {
            z[i] = y[0][i];
        }

        // Transfer x to y
        *y = (short *) realloc(*y, local_length_x * sizeof(short));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = x[0][i];
        }

        // Transfer z to x
        *x = (short *) realloc(*x, local_length_y * sizeof(short));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = z[i];
        }

        free(z);
    }
    else
    {
        // Transfer x to z
        short *z = (short *) malloc(local_length_x * sizeof(short));

        UINT i = 0;
        for( ; i < local_length_x; i++)
        {
            z[i] = x[0][i];
        }

        // Transfer y to x
        *x = (short *) realloc(*x, local_length_y * sizeof(short));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = y[0][i];
        }

        // Transfer z to y
        *y = (short *) realloc(*y, local_length_x * sizeof(short));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = z[i];
        }

        free(z);
    }
}

// long
void swap_vectors_long(long **x, UINT *length_x, long **y, UINT *length_y)
{
    UINT local_length_x = *length_x;
    UINT local_length_y = *length_y;

    // Swap lengths for the user
    swap_uint(length_x, length_y);

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        long *z = (long *) malloc(local_length_y * sizeof(long));

        UINT i = 0;
        for( ; i < local_length_y; i++)
        {
            z[i] = y[0][i];
        }

        // Transfer x to y
        *y = (long *) realloc(*y, local_length_x * sizeof(long));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = x[0][i];
        }

        // Transfer z to x
        *x = (long *) realloc(*x, local_length_y * sizeof(long));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = z[i];
        }

        free(z);
    }
    else
    {
        // Transfer x to z
        long *z = (long *) malloc(local_length_x * sizeof(long));

        UINT i = 0;
        for( ; i < local_length_x; i++)
        {
            z[i] = x[0][i];
        }

        // Transfer y to x
        *x = (long *) realloc(*x, local_length_y * sizeof(long));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = y[0][i];
        }

        // Transfer z to y
        *y = (long *) realloc(*y, local_length_x * sizeof(long));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = z[i];
        }

        free(z);
    }
}

//float
void swap_vectors_float(float **x, UINT *length_x, float **y, UINT *length_y)
{
    UINT local_length_x = *length_x;
    UINT local_length_y = *length_y;

    // Swap lengths for the user
    swap_uint(length_x, length_y);

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        float *z = (float *) malloc(local_length_y * sizeof(float));

        UINT i = 0;
        for( ; i < local_length_y; i++)
        {
            z[i] = y[0][i];
        }

        // Transfer x to y
        *y = (float *) realloc(*y, local_length_x * sizeof(float));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = x[0][i];
        }

        // Transfer z to x
        *x = (float *) realloc(*x, local_length_y * sizeof(float));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = z[i];
        }

        free(z);
    }
    else
    {
        // Transfer x to z
        float *z = (float *) malloc(local_length_x * sizeof(float));

        UINT i = 0;
        for( ; i < local_length_x; i++)
        {
            z[i] = x[0][i];
        }

        // Transfer y to x
        *x = (float *) realloc(*x, local_length_y * sizeof(float));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = y[0][i];
        }

        // Transfer z to y
        *y = (float *) realloc(*y, local_length_x * sizeof(float));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = z[i];
        }

        free(z);
    }
}

// double
void swap_vectors_double(double **x, UINT *length_x, double **y, UINT *length_y)
{
    UINT local_length_x = *length_x;
    UINT local_length_y = *length_y;

    // Swap lengths for the user
    swap_uint(length_x, length_y);

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        double *z = (double *) malloc(local_length_y * sizeof(double));

        UINT i = 0;
        for( ; i < local_length_y; i++)
        {
            z[i] = y[0][i];
        }

        // Transfer x to y
        *y = (double *) realloc(*y, local_length_x * sizeof(double));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = x[0][i];
        }

        // Transfer z to x
        *x = (double *) realloc(*x, local_length_y * sizeof(double));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = z[i];
        }

        free(z);
    }
    else
    {
        // Transfer x to z
        double *z = (double *) malloc(local_length_x * sizeof(double));

        UINT i = 0;
        for( ; i < local_length_x; i++)
        {
            z[i] = x[0][i];
        }

        // Transfer y to x
        *x = (double *) realloc(*x, local_length_y * sizeof(double));

        for(i = 0; i < local_length_y; i++)
        {
            x[0][i] = y[0][i];
        }

        // Transfer z to y
        *y = (double *) realloc(*y, local_length_x * sizeof(double));

        for(i = 0; i < local_length_x; i++)
        {
            y[0][i] = z[i];
        }

        free(z);
    }
}

/******************************************************************************/
// swap
/******************************************************************************/

// int
void swap_int(int *a, int *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

// UINT
void swap_uint(UINT *a, UINT *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

// short
void swap_short(short *a, short *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

// long
void swap_long(long *a, long *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

// float
void swap_float(float *a, float *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

//double
void swap_double(double *a, double *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

/******************************************************************************/
// zero_pad_fb
/******************************************************************************/

// int
UINT zero_pad_fb_int(int **result, int *x, UINT length_x, UINT PAD_SIZE)
{
    UINT length_result;

    int *x_base = x;

    length_result = (length_x + (2 * PAD_SIZE));

    *result = (int *) calloc(length_result, sizeof(int));

    UINT i = 0;
    for( ; i < length_result; i++)
    {
        if(!((i < PAD_SIZE) || (i >= (length_result - PAD_SIZE))))
        {
            result[0][i] = *(x++);
        }
    }

    x = x_base;
    return length_result;
}

// short
UINT zero_pad_fb_short(short **result, short *x, UINT length_x, UINT PAD_SIZE)
{
    UINT length_result;

    short *x_base = x;

    length_result = (length_x + (2 * PAD_SIZE));

    *result = (short *) calloc(length_result, sizeof(short));

    UINT i = 0;
    for( ; i < length_result; i++)
    {
        if(!((i < PAD_SIZE) || (i >= (length_result - PAD_SIZE))))
        {
            result[0][i] = *(x++);
        }
    }

    x = x_base;
    return length_result;
}

// long
UINT zero_pad_fb_long(long **result, long *x, UINT length_x, UINT PAD_SIZE)
{
    UINT length_result;

    long *x_base = x;

    length_result = (length_x + (2 * PAD_SIZE));

    *result = (long *) calloc(length_result, sizeof(long));

    UINT i = 0;
    for( ; i < length_result; i++)
    {
        if(!((i < PAD_SIZE) || (i >= (length_result - PAD_SIZE))))
        {
            result[0][i] = *(x++);
        }
    }

    x = x_base;
    return length_result;
}

// float
UINT zero_pad_fb_float(float **result, float *x, UINT length_x, UINT PAD_SIZE)
{
    UINT length_result;

    float *x_base = x;

    length_result = (length_x + (2 * PAD_SIZE));

    *result = (float *) calloc(length_result, sizeof(float));

    UINT i = 0;
    for( ; i < length_result; i++)
    {
        if(!((i < PAD_SIZE) || (i >= (length_result - PAD_SIZE))))
        {
            result[0][i] = *(x++);
        }
    }

    x = x_base;
    return length_result;
}

// double
UINT zero_pad_fb_double(double **result, double *x, UINT length_x, UINT PAD_SIZE)
{
    UINT length_result;

    double *x_base = x;

    length_result = (length_x + (2 * PAD_SIZE));

    *result = (double *) calloc(length_result, sizeof(double));

    UINT i = 0;
    for( ; i < length_result; i++)
    {
        if(!((i < PAD_SIZE) || (i >= (length_result - PAD_SIZE))))
        {
            result[0][i] = *(x++);
        }
    }

    x = x_base;
    return length_result;
}

/******************************************************************************/
// flip_vector
/******************************************************************************/

// int
void flip_vector_int(int *x, UINT length_x)
{
    int *temp = (int *) malloc(length_x * sizeof(int));

    UINT i = 0;
    for( ; i < length_x; i++)
    {
        temp[(length_x - 1) - i] = x[i];
    }

    for(i = 0; i < length_x; i++)
    {
        x[i] = temp[i];
    }

    free(temp);
}

// short
void flip_vector_short(short *x, UINT length_x)
{
    short *temp = (short *) malloc(length_x * sizeof(short));

    UINT i = 0;
    for( ; i < length_x; i++)
    {
        temp[(length_x - 1) - i] = x[i];
    }

    for(i = 0; i < length_x; i++)
    {
        x[i] = temp[i];
    }

    free(temp);
}

// long
void flip_vector_long(long *x, UINT length_x)
{
    long *temp = (long *) malloc(length_x * sizeof(long));

    UINT i = 0;
    for( ; i < length_x; i++)
    {
        temp[(length_x - 1) - i] = x[i];
    }

    for(i = 0; i < length_x; i++)
    {
        x[i] = temp[i];
    }

    free(temp);
}

// float
void flip_vector_float(float *x, UINT length_x)
{
    float *temp = (float *) malloc(length_x * sizeof(float));

    UINT i = 0;
    for( ; i < length_x; i++)
    {
        temp[(length_x - 1) - i] = x[i];
    }

    for(i = 0; i < length_x; i++)
    {
        x[i] = temp[i];
    }

    free(temp);
}

// double
void flip_vector_double(double *x, UINT length_x)
{
    double *temp = (double *) malloc(length_x * sizeof(double));

    UINT i = 0;
    for( ; i < length_x; i++)
    {
        temp[(length_x - 1) - i] = x[i];
    }

    for(i = 0; i < length_x; i++)
    {
        x[i] = temp[i];
    }

    free(temp);
}

/******************************************************************************/
// conv
/******************************************************************************/

// int
UINT conv_int(int **result, int **x, UINT length_x, int **y, UINT length_y)
{
    UINT N, M, length_result, length_xpfb;
    UINT vector_swap = 0;

    int *xpfb;

    if(length_x < length_y)
    {
        swap_vectors_int(x, &length_x, y, &length_y);
        vector_swap = 1;
    }

    N = length_x;
    M = length_y;
    length_result = ((M + N) - 1);

    length_xpfb = zero_pad_fb_int(&xpfb, *x, length_x, M-1);

    *result = (int *) calloc(N + M - 1, sizeof(int));

    int *xpfb_base = xpfb;

    int *temp_base = xpfb_base;
    int temp_sum;

    // Temporarily flip y for convenience
    flip_vector_int(*y, length_y);

    UINT i = 0;
    UINT ii;
    for( ; i < length_result; i++)
    {
        //result(i) = sum(y.*x(n:1:n+(M-1)));
        temp_sum = 0;
        for(ii = 0; ii < length_y; ii++)
        {
            temp_sum += y[0][ii] * xpfb[ii];
        }

        result[0][i] = temp_sum;

        xpfb = ++temp_base;
    }

    xpfb = xpfb_base;

    // Flip y Back
    flip_vector_int(*y, length_y);

    if(vector_swap)
    {
        swap_vectors_int(x, &length_x, y, &length_y);
    }

    return length_result;
}

// short
UINT conv_short(short **result, short **x, UINT length_x, short **y, UINT length_y)
{
    UINT N, M, length_result, length_xpfb;
    UINT vector_swap = 0;

    short *xpfb;

    if(length_x < length_y)
    {
        swap_vectors_short(x, &length_x, y, &length_y);
        vector_swap = 1;
    }

    N = length_x;
    M = length_y;
    length_result = ((M + N) - 1);

    length_xpfb = zero_pad_fb_short(&xpfb, *x, length_x, M-1);

    *result = (short *) calloc(N + M - 1, sizeof(short));

    short *xpfb_base = xpfb;

    short *temp_base = xpfb_base;
    short temp_sum;

    // Temporarily flip y for convenience
    flip_vector_short(*y, length_y);

    UINT i = 0;
    UINT ii;
    for( ; i < length_result; i++)
    {
        //result(i) = sum(y.*x(n:1:n+(M-1)));
        temp_sum = 0;
        for(ii = 0; ii < length_y; ii++)
        {
            temp_sum += y[0][ii] * xpfb[ii];
        }

        result[0][i] = temp_sum;

        xpfb = ++temp_base;
    }

    xpfb = xpfb_base;

    // Flip y Back
    flip_vector_short(*y, length_y);

    if(vector_swap)
    {
        swap_vectors_short(x, &length_x, y, &length_y);
    }

    return length_result;
}

// long
UINT conv_long(long **result, long **x, UINT length_x, long **y, UINT length_y)
{
    UINT N, M, length_result, length_xpfb;
    UINT vector_swap = 0;

    long *xpfb;

    if(length_x < length_y)
    {
        swap_vectors_long(x, &length_x, y, &length_y);
        vector_swap = 1;
    }

    N = length_x;
    M = length_y;
    length_result = ((M + N) - 1);

    length_xpfb = zero_pad_fb_long(&xpfb, *x, length_x, M-1);

    *result = (long *) calloc(N + M - 1, sizeof(long));

    long *xpfb_base = xpfb;

    long *temp_base = xpfb_base;
    long temp_sum;

    // Temporarily flip y for convenience
    flip_vector_long(*y, length_y);

    UINT i = 0;
    UINT ii;
    for( ; i < length_result; i++)
    {
        //result(i) = sum(y.*x(n:1:n+(M-1)));
        temp_sum = 0;
        for(ii = 0; ii < length_y; ii++)
        {
            temp_sum += y[0][ii] * xpfb[ii];
        }

        result[0][i] = temp_sum;

        xpfb = ++temp_base;
    }

    xpfb = xpfb_base;

    // Flip y Back
    flip_vector_long(*y, length_y);

    if(vector_swap)
    {
        swap_vectors_long(x, &length_x, y, &length_y);
    }

    return length_result;
}

// float
UINT conv_float(float **result, float **x, UINT length_x, float **y, UINT length_y)
{
    UINT N, M, length_result, length_xpfb;
    UINT vector_swap = 0;

    float *xpfb;

    if(length_x < length_y)
    {
        swap_vectors_float(x, &length_x, y, &length_y);
        vector_swap = 1;
    }

    N = length_x;
    M = length_y;
    length_result = ((M + N) - 1);

    length_xpfb = zero_pad_fb_float(&xpfb, *x, length_x, M-1);

    *result = (float *) calloc(N + M - 1, sizeof(float));

    float *xpfb_base = xpfb;

    float *temp_base = xpfb_base;
    float temp_sum;

    // Temporarily flip y for convenience
    flip_vector_float(*y, length_y);

    UINT i = 0;
    UINT ii;
    for( ; i < length_result; i++)
    {
        //result(i) = sum(y.*x(n:1:n+(M-1)));
        temp_sum = 0;
        for(ii = 0; ii < length_y; ii++)
        {
            temp_sum += y[0][ii] * xpfb[ii];
        }

        result[0][i] = temp_sum;

        xpfb = ++temp_base;
    }

    xpfb = xpfb_base;

    // Flip y Back
    flip_vector_float(*y, length_y);

    if(vector_swap)
    {
        swap_vectors_float(x, &length_x, y, &length_y);
    }

    return length_result;
}

// double
UINT conv_double(double **result, double **x, UINT length_x, double **y, UINT length_y)
{
    UINT N, M, length_result, length_xpfb;
    UINT vector_swap = 0;

    double *xpfb;

    if(length_x < length_y)
    {
        swap_vectors_double(x, &length_x, y, &length_y);
        vector_swap = 1;
    }

    N = length_x;
    M = length_y;
    length_result = ((M + N) - 1);

    length_xpfb = zero_pad_fb_double(&xpfb, *x, length_x, M-1);

    *result = (double *) calloc(N + M - 1, sizeof(double));

    double *xpfb_base = xpfb;

    double *temp_base = xpfb_base;
    double temp_sum;

    // Temporarily flip y for convenience
    flip_vector_double(*y, length_y);

    UINT i = 0;
    UINT ii;
    for( ; i < length_result; i++)
    {
        //result(i) = sum(y.*x(n:1:n+(M-1)));
        temp_sum = 0;
        for(ii = 0; ii < length_y; ii++)
        {
            temp_sum += y[0][ii] * xpfb[ii];
        }

        result[0][i] = temp_sum;

        xpfb = ++temp_base;
    }

    xpfb = xpfb_base;

    // Flip y Back
    flip_vector_double(*y, length_y);

    if(vector_swap)
    {
        swap_vectors_double(x, &length_x, y, &length_y);
    }

    return length_result;
}
