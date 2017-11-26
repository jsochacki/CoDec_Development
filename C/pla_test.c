#include <stdlib.h>
#include <stdio.h>
#include <pal/pal_dsp.h>

// FROM THE TEST BELOW WE CAN SEE THAT PLA IS BAD AND
// SHOULD NOT BE USED!!!!!!!!

void main()
{
    int nx = 10;
    int nh = 20;
    int nr = nx + nh - 1;

    float *x = (float *) malloc(nx * sizeof(float));
    float *h = (float *) malloc(nh * sizeof(float));
    float *r = (float *) calloc(nr, sizeof(float));

    int i = 0;
    for( ; i < nx; i++)
    {
        x[i] = i;
    }

    for( i = 0; i < nh; i++)
    {
        h[i] = i;
    }

    p_conv_f32(x, h, r, nx, nh);

    for( i = 0; i < nr; i++)
    {
        printf("value %d is %d \n", i, r[i]);
    }
    // correct result is 0 0 1 4 10 20 35 56 84 120 165 210 255 300
    //345 390 435 480 525 570 615 640 644 626 585 520 430 314 171

}
