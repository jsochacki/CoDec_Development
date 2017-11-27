
#include "socHACKi_debug_macros.h"

#include "socHACKi_float_signal_processing.h"

#include "socHACKi_constants.h"

typedef float WTYPE;
typedef complex float CWTYPE;

void main()
{
    UINT i = 0;
    UINT BINS = 32;
    UINT length_x = 32;
    UINT length_result2;
    CWTYPE *x = (CWTYPE *) malloc(length_x * sizeof(CWTYPE));
    CWTYPE *result = (CWTYPE *) malloc(BINS * sizeof(CWTYPE));
    CWTYPE *result2 = (CWTYPE *) malloc(BINS * sizeof(CWTYPE));

    initialize_ramp(x, length_x);

    for(i = 0; i < length_x; i++)
    {
        DISPLAYCOMPLEXV((x[i]))
    }

    // default complex is double (16 bytes)
    // also supports float (8 bytes) and long double (32 bytes)
    CWTYPE temp_value;
    UINT n, k;
    for(k = 0; k < BINS; k++)
    {
        temp_value = 0;
        for(n = 0; n < length_x; n++)
        {
            temp_value += x[n] *
                            cexpf((-I * 2 * M_PI * (CWTYPE) k * (CWTYPE) n)
                            / ((CWTYPE) BINS));
        }
        result[k] = temp_value;
        DISPLAYCOMPLEXV((result[k]))
    }

    length_result2 = conv(&result2, &x, length_x, &result, BINS);

    for(i = 0; i < length_result2; i++)
    {
        DISPLAYCOMPLEXV((result2[i]))
    }

}
