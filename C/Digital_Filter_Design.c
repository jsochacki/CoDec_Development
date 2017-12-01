
#include "socHACKi_debug_macros.h"

#include "socHACKi_float_signal_processing.h"

#include "socHACKi_math_h_overloading.h"

#include "socHACKi_constants.h"

typedef float WTYPE;
typedef CFLOAT CWTYPE;

int main(void)
{
    WTYPE temp1, temp2, temp3, temp4;
    CWTYPE ctemp1, ctemp2, ctemp3, ctemp4;
    UINT index, index1, index2, index3;

    // Enter Filter Design Parameters
    WTYPE sampling_frequency = 1;
    WTYPE pass_band_frequency = 0.3;  // stop_band_frequency Is The Max
    WTYPE stop_band_frequency = 0.4;  // 0.5 Is The Max
    WTYPE ripple = 0.001; // Peak to Peak Ripple In dB
    WTYPE rejection = 60; // Stop Band Minimum Rejection In dB


    // Calculate Derived Parameters
    WTYPE pass_band_omega = (WTYPE) 2 * (WTYPE) M_PI *
                    (pass_band_frequency / sampling_frequency);
    WTYPE stop_band_omega = (WTYPE) 2 * (WTYPE) M_PI *
                    (stop_band_frequency / sampling_frequency);

    WTYPE eta = power((WTYPE) 10, ripple / (WTYPE)10);
    WTYPE A2 = power((WTYPE)10, rejection / (WTYPE)10);

    // Due to macro expansion you have to evaluate power before you
    // can pass the result to sqrt or else sqrt doesnt know which
    // function to call due to a lack of type
    eta = sqrt(eta - (WTYPE) 1);
    A2 = sqrt(A2 - (WTYPE) 1);

    WTYPE c = ((WTYPE) 1) / tan(pass_band_omega / (WTYPE) 2);

    WTYPE pre_warped_pass_band_omega = c * tan(pass_band_omega / (WTYPE) 2);
    WTYPE pre_warped_stop_band_omega = c * tan(stop_band_omega / (WTYPE) 2);

    // Calculating M
    temp1 = power((WTYPE) (A2 / eta), (WTYPE) 2);
    temp1 = sqrt((WTYPE) (temp1 - (WTYPE) 1));
    temp2 = power((WTYPE) (pre_warped_stop_band_omega
                            / pre_warped_pass_band_omega), (WTYPE) 2);
    temp2 = sqrt((WTYPE) (temp2 - (WTYPE) 1));
    temp3 = log((A2 / eta) + temp1);
    temp4 = log((pre_warped_stop_band_omega
                / pre_warped_pass_band_omega) + temp2);
    WTYPE M = temp3 / temp4;

    UINT N = (UINT) ceil(M);

    CWTYPE *poles = (CWTYPE *) malloc(N * sizeof(CWTYPE));
    UINT n = N;

    temp1 = power((WTYPE) eta, 2);
    temp2 = sqrt(1 + (1 / temp1));
    WTYPE gammav = power((WTYPE) ((((WTYPE) 1) / eta) + temp2), ((WTYPE) 1) / ((WTYPE) N));
    WTYPE O1 = -(gammav - (((WTYPE) 1) / gammav)) / (WTYPE) 2;
    WTYPE O2 = (gammav + (((WTYPE) 1) / gammav)) / (WTYPE) 2;

    WTYPE sigma, omega;
    index = 0;

    while(n)
    {
        temp1 = (((WTYPE) ((2 * n) - 1)) * M_PI) / ((WTYPE) (2 * ((WTYPE) N)));
        sigma = O1 * sin((WTYPE) temp1);
        omega = O2 * cos((WTYPE) temp1);
        poles[index] = sigma + (I * omega);
        index++;
        n--;
    }

    CWTYPE *z = (CWTYPE *) malloc(N * sizeof(CWTYPE));

    for(index = 0; index < N; index++)
    {
        printf("pole %d is %f+j%f\n", index, crealf(poles[index]), cimagf(poles[index]));
        z[index] = (((CWTYPE) 1) + poles[index] / (CWTYPE) c)
                    / (((CWTYPE) 1) - poles[index] / (CWTYPE) c);
    }

    UINT EOO = mod(N, 2);

    UINT a_length = (((N - 1) / 2) * 3) + (EOO * 2);
    UINT b_length = a_length;

    WTYPE *a = (WTYPE *) malloc(a_length * sizeof(WTYPE));
    WTYPE *b = (WTYPE *) malloc(b_length * sizeof(WTYPE));
    n = N;
    index1 = 0;
    index2 = 0;
    index3 = (UINT)((N - 1) / 2); // Location of the odd pole if exhists
    EOO = mod(n, 2);
    while(n)
    {
        if(EOO)
        {
            a[0] = 1;
            ctemp1 = z[index3];
            a[1] = real( ctemp1 );
            b[0] = 1;
            b[1] = 1;
            n--;
            index1 = 2;
            EOO = mod(n, 2);
        }
        a[index1] = 1;
        ctemp1 = z[index2] + z[N - 1 - index2];
        a[index1 + 1] = real( ctemp1 );
        ctemp2 = -z[index2] * z[N - 1 - index2];
        a[index1 + 2] = real( ctemp2 );
        b[index1]     = 1;
        b[index1 + 1] = 2;
        b[index1 + 2] = 1;
        index1 += 3;
        index2 +=1;
        n -= 2;
    }

    for(index = 0; index < N; index++)
    {
        printf("z %d is %f+j%f\n", index, crealf(z[index]), cimagf(z[index]));
    }

    for(index = 0; index < a_length; index++)
    {
        printf("a is %f and b is %f\n", a[index], b[index]);
    }

    WTYPE product = 0;
    EOO = mod(N, 2);
    if(EOO)
    {
        product = (b[0] + b[1]) / (a[0] - a[1]);
        index = 2;
    }
    else
    {
        product = (b[0] + b[1] + b[2]) / (a[0] - a[1] - a[2]);
        index = 3;
    }

    for( ; index < a_length; index += 3)
    {
        product *= (b[index] + b[index + 1] + b[index + 2])
                    / (a[index] - a[index + 1] - a[index + 2]);
    }

    WTYPE filter_gain = 0;

    if(EOO)
    {
        filter_gain = 1 / product;
    }
    else
    {
        temp1 = power(eta, 2);
        temp2 = sqrt(1 + temp1);
        filter_gain = ((WTYPE) 1) / (temp2 * product);
    }

    EOO = mod(N, 2);
    UINT cur_length;
    WTYPE *a_cur, *b_cur;
    if(EOO)
    {
        cur_length = 2;
        a_cur = (WTYPE *) malloc(cur_length * sizeof(WTYPE));
        b_cur = (WTYPE *) malloc(cur_length * sizeof(WTYPE));
        a_cur[0] = a[0];
        a_cur[1] = - a[1];
        b_cur[0] = b[0];
        b_cur[1] = b[1];
    }
    else
    {
        cur_length = 3;
        a_cur = (WTYPE *) malloc(cur_length * sizeof(WTYPE));
        b_cur = (WTYPE *) malloc(cur_length * sizeof(WTYPE));
        a_cur[0] = a[0];
        a_cur[1] = - a[1];
        a_cur[2] = - a[2];
        b_cur[0] = b[0];
        b_cur[1] = b[1];
        b_cur[2] = b[2];
    }

    index = cur_length;

    UINT ini_length = 3;
    WTYPE *a_ini = (WTYPE *) malloc(ini_length * sizeof(WTYPE));
    WTYPE *b_ini = (WTYPE *) malloc(ini_length * sizeof(WTYPE));

    WTYPE *resulta, *resultb;
    UINT resulta_length, resultb_length;
    for( ; index < a_length; index += ini_length)
    {
        a_ini[0] = a[index];
        a_ini[1] = a[index + 1];
        a_ini[2] = a[index + 2];
        b_ini[0] = b[index];
        b_ini[1] = b[index + 1];
        b_ini[2] = b[index + 2];
        resulta_length = conv(&resulta, &a_cur, cur_length, &a_ini, ini_length);
        resultb_length = conv(&resultb, &b_cur, cur_length, &b_ini, ini_length);
//THERE IS AN ISSUE WITH THE A RESULT AT THIS POINT BUT NOT THE B RESULT
        a_cur = (WTYPE *) realloc(a_cur, resulta_length * sizeof(WTYPE));
        b_cur = (WTYPE *) realloc(b_cur, resultb_length * sizeof(WTYPE));

        for(index2 = 0; index2 < resulta_length; index2++)
        {
            a_cur[index2] = resulta[index2];
            b_cur[index2] = resultb[index2];
        }
        cur_length = resulta_length;
    }

    for(index3 = 0; index3 < resulta_length; index3++)
    {
        DISPLAYF(resulta[index3])
    }

    for(index3 = 0; index3 < resultb_length; index3++)
    {
        DISPLAYF(resultb[index3])
    }
}
