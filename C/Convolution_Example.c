
#include "socHACKi_debug_macros.h"

#include "socHACKi_float_signal_processing.h"

int main()
{
    int i, ii;
    int length_x = 10;
    int length_y = 20;
    int length_result;

    float *x, *y, *result;

    // only calloc gives you initialized to all zeros
    // so is equivalent to zeros(a,b) in matlab
    // malloc and realloc give you whatever is there
    x = (float *) malloc(length_x * sizeof(float));
    y = (float *) malloc(length_y * sizeof(float));

    initialize_ramp(x, length_x);
    initialize_ramp(y, length_y);

    length_result = conv(&result, &x, length_x, &y, length_y);

    DISPLAYS("this is x \n")
    for(i = 0; i < length_x; i++)
    {
        DISPLAYV(x[i])
    }
    DISPLAYNL
    DISPLAYS("this is y \n")
    for(i = 0; i < length_y; i++)
    {
        DISPLAYV(y[i])
    }
    DISPLAYNL
    DISPLAYS("this is result \n")
    for(i = 0; i < length_result; i++)
    {
        DISPLAYV(result[i])
    }
    DISPLAYNL
}
