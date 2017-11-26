
#include "socHACKi_debug_macros.h"

#include "socHACKi_float_signal_processing.h"

#define WTYPE int

int main()
{
    UINT i, ii;
    UINT length_x = 10;
    UINT length_y = 20;
    UINT length_result;

    WTYPE *x, *y, *result;

    // only calloc gives you initialized to all zeros
    // so is equivalent to zeros(a,b) in matlab
    // malloc and realloc give you whatever is there
    x = (WTYPE *) malloc(length_x * sizeof(WTYPE));
    y = (WTYPE *) malloc(length_y * sizeof(WTYPE));

    initialize_ramp_int(x, length_x);
    initialize_ramp_int(y, length_y);

    length_result = conv_int(&result, &x, length_x, &y, length_y);

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
