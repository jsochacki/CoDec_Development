#include <stdlib.h>
#include <iostream>
#include <string.h>

#include <complex.h>
#include <stdio.h>

#include <math.h>

#define DISPLAY(x) std::cout << "The variable value is " << x << std::endl;
#define DISPLAY2(x,y) std::cout << "The variable values are " << x << " and " << y << std::endl;

void initialize_ramp(float *x, int length_x);
void swap_vectors(float **x, int *length_x, float **y, int *length_y);
void swap_ints(int *a, int *b);
void zero_pad_fb(float **x, int *length_x, int PAD_SIZE);
void flip_float_vector(float *x, int length_x);

int main()
{
    int i, ii;
    int length_x = 10;
    int length_y = 20;
    int N, M;
    float *x, *y;

    // only calloc gives you initialized to all zeros
    // so is equivalent to zeros(a,b) in matlab
    // malloc and realloc give you whatever is there
    x = (float *) malloc(length_x * sizeof(float));

    // only calloc gives you initialized to all zeros
    // so is equivalent to zeros(a,b) in matlab
    // malloc and realloc give you whatever is there
    y = (float *) malloc(length_y * sizeof(float));


    initialize_ramp(x, length_x);
    initialize_ramp(y, length_y);

    for (i = 0; i < length_x; i++)
    {
        DISPLAY(*(x+i))
    }

    for (i = 0; i < length_y; i++)
    {
        DISPLAY(*(y+i))
    }

    DISPLAY(length_x)
    DISPLAY(length_y)

    if(length_x < length_y)
    {
        swap_vectors(&x, &length_x, &y, &length_y);
    }

    DISPLAY(length_x)
    DISPLAY(length_y)

    for (i = 0; i < length_x; i++)
    {
        DISPLAY(*(x+i))
    }

    for (i = 0; i < length_y; i++)
    {
        DISPLAY(*(y+i))
    }

    N = length_x;
    M = length_y;
    zero_pad_fb(&x, &length_x, M-1);


    for (i = 0; i < length_x; i++)
    {
        DISPLAY2(i, *(x+i))
    }

    //Convert to C code
    float *result = (float *) calloc(N + M - 1, sizeof(float));
    float *result_base = result;

    float *x_base = x;
    float *y_base = y;

    float *temp_base = x_base;
    float temp_sum;

    // Temporarily flip y for convenience
    flip_float_vector(y, length_y);
    for(i = 0; i < ((M + N) - 1); i++)
    {
        //Convert to C code
        //result(i) = sum(y.*x(n:1:n+(M-1)));
        temp_sum = 0;
        for(ii = 0; ii < length_y; ii++)
        {
            temp_sum += *(y++) * *(x++);
        }

        *(result++) = temp_sum;

        y = y_base;
        x = ++temp_base;
    }

    result = result_base;
    x = x_base;
    y = y_base;
    // Flip y Back
    flip_float_vector(y, length_y);

    for(i = 0; i < ((M + N) - 1); i++)
    {
        DISPLAY(*(result++))
    }
}

//float conv(float *x, int length_x, float *y, int length_y)
//{
//
//}

void initialize_ramp(float *x, int length_x)
{
    float *x_base;

    // Save the base address for post initialization
    // return to bass
    x_base = x;

    // Ramp initialize
    for (int i = 0; i < length_x; i++)
    {
        *(x++) = i;
    }

    // Return to base
    x = x_base;
}

void swap_vectors(float **x, int *length_x, float **y, int *length_y)
{
    float *x_base, *y_base, *z_base;
    int local_length_x = *length_x;
    int local_length_y = *length_y;

    // Swap lengths for the user
    swap_ints(length_x, length_y);

    // Save base locations
    x_base = *x;
    y_base = *y;

    if (local_length_x < local_length_y)
    {
        // Transfer y to z
        float *z = (float *) malloc(local_length_y * sizeof(float));

        z_base = z;

        for(int i = 0; i < local_length_y; i++)
        {
            *(z++) = *((*y)++);
        }

        z = z_base;
        *y = y_base;

        // Transfer x to y
        *y = (float *) realloc(*y, local_length_x * sizeof(float));

        y_base = *y;

        for(int i = 0; i < local_length_x; i++)
        {
            *((*y)++) = *((*x)++);
        }

        *x = x_base;
        *y = y_base; // This is now technically *x in this local

        // Transfer z to x
        *x = (float *) realloc(*x, local_length_y * sizeof(float));

        x_base = *x;

        for(int i = 0; i < local_length_y; i++)
        {
            *((*x)++) = *(z++);
        }

        *x = x_base; // This is now technically *y in this local
        z = z_base;

        free(z);
    }
    else
    {
        // Transfer x to z
        float *z = (float *) malloc(local_length_x * sizeof(float));

        z_base = z;

        for(int i = 0; i < local_length_x; i++)
        {
            *(z++) = *((*x)++);
        }

        z = z_base;
        *x = x_base;

        // Transfer y to x
        *x = (float *) realloc(*x, local_length_y * sizeof(float));

        x_base = *x;

        for(int i = 0; i < local_length_y; i++)
        {
            *((*x)++) = *((*y)++);
        }

        *y = y_base;
        *x = x_base; // This is now technically *y in this local

        // Transfer z to y
        *y = (float *) realloc(*y, local_length_x * sizeof(float));

        y_base = *y;

        for(int i = 0; i < local_length_x; i++)
        {
            *((*y)++) = *(z++);
        }

        *y = y_base; // This is now technically *x in this local
        z = z_base;

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

void zero_pad_fb(float **x, int *length_x, int PAD_SIZE)
{
    int i;

    float *x_base = *x;
    float *temp;
    float *temp_base;

    int local_length_x = *length_x;

    *length_x = (local_length_x + (2 * PAD_SIZE));

    temp = (float *) malloc(local_length_x * sizeof(float));
    temp_base = temp;

    for(i = 0; i < local_length_x; i++)
    {
        *(temp++) = *((*x)++);
    }

    *x = x_base;
    temp = temp_base;

    *x = (float *) realloc(*x, *length_x * sizeof(float));

    x_base = *x;

    for(i = 0; i < *length_x; i++)
    {
        if((i < PAD_SIZE) || (i >= (*length_x - PAD_SIZE)))
        {
            *((*x)++) = 0;
        }
        else
        {
            *((*x)++) = *(temp++);
        }
    }

    *x = x_base;
    temp = temp_base;

    free(temp);
}

void flip_float_vector(float *x, int length_x)
{
    float *x_base = x;

    float *temp = (float *) malloc(length_x * sizeof(float));
    float *temp_base = temp;

    for(int i = 0; i < length_x; i++)
    {
        *(temp + (length_x - 1) - i ) = *(x++);
    }

    x = x_base;
    for(int i = 0; i < length_x; i++)
    {
        *(x++) = *(temp++);
    }

    x = x_base;
    temp = temp_base;

    free(temp);
}
