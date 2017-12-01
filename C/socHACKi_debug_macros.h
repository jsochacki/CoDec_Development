/******************************************************************************/
#ifndef SOCHACKI_DM

#define SOCHACKI_DM
/******************************************************************************/
#include <stdio.h>#include <math.h>#include <complex.h>

#define DISPLAYV(x) printf("The variable value is %d \n", (int)x);#define DISPLAYF(x) printf("The variable value is %f \n", (float)x);#define DISPLAYD(x) printf("The variable value is %d \n", (double)x);#define DISPLAYCOMPLEXV(value) printf("%lf + %lfi\n", creal(value), cimag(value));
#define DISPLAY2V(x,y) printf("The variable values are %d and %d \n", (int)x, (int)y);
#define DISPLAYS(x) printf("%s", x);
#define DISPLAYNL printf("\n");

#endif // SOCHACKI_FSP
