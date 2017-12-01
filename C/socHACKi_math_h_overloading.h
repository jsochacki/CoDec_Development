/******************************************************************************/

#ifndef SOCHACKI_MATH_H_OVERLOADING

#define SOCHACKI_MATH_H_OVERLOADING

/******************************************************************************/

#include "socHACKi_types.h"
#include <math.h>
#include <complex.h>
// default complex is double (16 bytes)
// also supports float (8 bytes) and long double (32 bytes)
// Also, if using any of the complex math functions make sure to link with m
// -Im

// Do overloading
// sqrt
#define sqrt(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    sqrtf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    sqrt(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    sqrtl(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    csqrtf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    csqrt(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    csqrtl(x),\
                    (void)0))))));

// pow
#define power(base, exp)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(base), float),\
                    powf(base, exp),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(base), double),\
                    pow(base, exp),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(base), long double),\
                    powl(base, exp),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(base), CFLOAT),\
                    cpowf(base, exp),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(base), CDOUBLE),\
                    cpow(base, exp),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(base), CLDOUBLE),\
                    cpowl(base, exp),\
                    (void)0))))));

// tan
#define tan(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    tanf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    tan(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    tanl(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    ctanf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    ctan(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    ctanl(x),\
                    (void)0))))));

// log
#define log(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    logf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    log(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    logl(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    clogf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    clog(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    clogl(x),\
                    (void)0))))));

// ceil
#define ceil(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    ceilf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    ceil(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    ceill(x),\
                    (void)0)));

// floor
#define floor(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    floorf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    floor(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    floorl(x),\
                    (void)0)));

// sin
#define sin(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    sinf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    sin(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    sinl(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    csinf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    csin(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    csinl(x),\
                    (void)0))))));

// cos
#define cos(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), float),\
                    cosf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), double),\
                    cos(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), long double),\
                    cosl(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    ccosf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    ccos(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    ccosl(x),\
                    (void)0))))));

// real
#define real(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    crealf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    creal(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    creall(x),\
                    (void)0)));

// imag
#define imag(x)\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CFLOAT),\
                    cimagf(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CDOUBLE),\
                    cimag(x),\
    __builtin_choose_expr(__builtin_types_compatible_p(typeof(x), CLDOUBLE),\
                    cimagl(x),\
                    (void)0)));

#endif /* SOCHACKI_MATH_H_OVERLOADING */
