
#include <stdlib.h>  // For malloc, calloc, realloc, etc...

int conv(float **result, float **x, int length_x, float **y, int length_y)
{
    int N, M, length_result, length_xpfb;
    int vector_swap = 0;

    float *xpfb;

    if(length_x < length_y)
    {
        swap_vectors(x, &length_x, y, &length_y);
        vector_swap = 1;
    }

    N = length_x;
    M = length_y;
    length_result = ((M + N) - 1);

    length_xpfb = zero_pad_fb(&xpfb, *x, length_x, M-1);

    *result = (float *) calloc(N + M - 1, sizeof(float));

    float *xpfb_base = xpfb;

    float *temp_base = xpfb_base;
    float temp_sum;

    // Temporarily flip y for convenience
    flip_float_vector(*y, length_y);

    int i = 0;
    int ii;
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
    flip_float_vector(*y, length_y);

    if(vector_swap)
    {
        swap_vectors(x, &length_x, y, &length_y);
    }

    return length_result;
}

void initialize_ramp(float *x, int length_x)
{
    // Ramp initialize
    int i = 0;
    for ( ; i < length_x; i++)
    {
        x[i] = i;
    }
}

void swap_vectors(float **x, int *length_x, float **y, int *length_y)
{
    int local_length_x = *length_x;
    int local_length_y = *length_y;

    // Swap lengths for the user
    swap_ints(length_x, length_y);

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        float *z = (float *) malloc(local_length_y * sizeof(float));

        int i = 0;
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

        int i = 0;
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

void swap_ints(int *a, int *b)
{
    // Swap lengths for the user
    *a = *a + *b;
    *b = *a - *b; // b = a + b - b = a
    *a = *a - *b; // a = a + b - a - b + b = a + b - a = b
}

int zero_pad_fb(float **result, float *x, int length_x, int PAD_SIZE)
{
    int length_result;

    float *x_base = x;

    length_result = (length_x + (2 * PAD_SIZE));

    *result = (float *) calloc(length_result, sizeof(float));

    int i = 0;
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

void flip_float_vector(float *x, int length_x)
{
    float *temp = (float *) malloc(length_x * sizeof(float));

    int i = 0;
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
