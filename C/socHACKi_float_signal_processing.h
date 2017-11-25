/******************************************************************************/
#ifndef SOCHACKI_FSP

#define SOCHACKI_FSP
/******************************************************************************/

void initialize_ramp(float *x, int length_x);
void swap_vectors(float **x, int *length_x, float **y, int *length_y);
void swap_ints(int *a, int *b);
int zero_pad_fb(float **result, float *x, int length_x, int PAD_SIZE);
void flip_float_vector(float *x, int length_x);
int conv(float **result, float **x, int length_x, float **y, int length_y);

#endif // SOCHACKI_FSP
