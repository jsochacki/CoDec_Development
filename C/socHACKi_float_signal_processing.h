/******************************************************************************/
#ifndef SOCHACKI_SP

#define SOCHACKI_SP
/******************************************************************************/
#include "socHACKi_types.h"// intvoid initialize_ramp_int(int *x, UINT length_x);void swap_vectors_int(int **x, UINT *length_x, int **y, UINT *length_y);void swap_int(int *a, int *b);UINT zero_pad_fb_int(int **result, int *x, UINT length_x, UINT PAD_SIZE);void flip_vector_int(int *x, UINT length_x);UINT conv_int(int **result, int **x, UINT length_x, int **y, UINT length_y);void swap_uint(UINT *a, UINT *b);// shortvoid initialize_ramp_short(short *x, UINT length_x);void swap_vectors_short(short **x, UINT *length_x, short **y, UINT *length_y);void swap_short(short *a, short *b);UINT zero_pad_fb_short(short **result, short *x, UINT length_x, UINT PAD_SIZE);void flip_vector_short(short *x, UINT length_x);UINT conv_short(short **result, short **x, UINT length_x, short **y, UINT length_y);// longvoid initialize_ramp_long(long *x, UINT length_x);void swap_vectors_long(long **x, UINT *length_x, long **y, UINT *length_y);void swap_long(long *a, long *b);UINT zero_pad_fb_long(long **result, long *x, UINT length_x, UINT PAD_SIZE);void flip_vector_long(long *x, UINT length_x);UINT conv_long(long **result, long **x, UINT length_x, long **y, UINT length_y);// Floatvoid initialize_ramp_float(float *x, UINT length_x);void swap_vectors_float(float **x, UINT *length_x, float **y, UINT *length_y);void swap_float(float *a, float *b);UINT zero_pad_fb_float(float **result, float *x, UINT length_x, UINT PAD_SIZE);void flip_vector_float(float *x, UINT length_x);UINT conv_float(float **result, float **x, UINT length_x, float **y, UINT length_y);// double
void initialize_ramp_double(double *x, UINT length_x);
void swap_vectors_double(double **x, UINT *length_x, double **y, UINT *length_y);
void swap_double(double *a, double *b);
UINT zero_pad_fb_double(double **result, double *x, UINT length_x, UINT PAD_SIZE);
void flip_vector_double(double *x, UINT length_x);
UINT conv_double(double **result, double **x, UINT length_x, double **y, UINT length_y);

#endif // SOCHACKI_SP
