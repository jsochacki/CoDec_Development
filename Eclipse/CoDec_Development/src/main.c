#include <stdio.h>
#include <gsl/gsl_matrix.h>
int main()
{
    gsl_matrix *a = gsl_matrix_alloc(2, 2);
    gsl_matrix *b = gsl_matrix_alloc(2, 2);
    gsl_matrix_set_zero(a);
    gsl_matrix_set_zero(b);
    int i = 0;
    int j = 0;
    for( ;i < 2; i++)
    {
        for(j = 0; j < 2; j++)
        {
            gsl_matrix_set(a, i, j, 1.0);
            gsl_matrix_set(b, i, j, 2.0);
        }
    }
    gsl_matrix_add(a, b);
    printf("matrix a : \n");
    for(i = 0; i < 2; i++)
    {
        for(j = 0; j < 2; j++)
        {
            printf("| %d |", (int) gsl_matrix_get(a, i, j));
        }
    printf("\n");
    }
    printf("matrix b : \n");
    for(i = 0; i < 2; i++)
    {
        for(j = 0; j < 2; j++)
        {
            printf("| %d |", (int) gsl_matrix_get(b, i, j));
        }
    printf("\n");
    }
    gsl_matrix_free(a);
    gsl_matrix_free(b);
    return 0;
}
