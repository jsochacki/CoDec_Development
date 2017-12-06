# include "gnuplot/gnuplot_i.h"

# include <stdlib.h>
# include <stdio.h>
# include <math.h>
# include <time.h>
# include <string.h>

int main ( );
double *correlation_damped_sine ( int n, double rho[], double rho0 );
void correlation_plot ( int n, double rho[], double c[], char *header,
  char *title );
double *r8vec_linspace_new ( int n, double a, double b );

/******************************************************************************/

int main ( )

/******************************************************************************/

{
  double *c;
  int n = 101;
  double *rho;
  double rho0;

  printf ( "\n" );
  printf ( "DAMPED_SINE\n" );
  printf ( "  C version\n" );
  printf ( "  Demonstrating how a correlation function can be\n" );
  printf ( "  evaluated and plotted using GNUPLOT.\n" );

  rho0 = 1.0;
  rho = r8vec_linspace_new ( n, -12.0, 12.0 );
  c = correlation_damped_sine ( n, rho, rho0 );
  correlation_plot ( n, rho, c, "damped_sine", "Damped sine correlation" );

  printf ( "\n" );
  printf ( "DAMPED_SINE\n" );
  printf ( "  Normal end of execution.\n" );

  printf ( "  NOT!!!!!!!!!!.\n" );

  gnuplot_ctrl *h, *j, *k;
  h = gnuplot_init();
  j = gnuplot_init();
  k = gnuplot_init();

  gnuplot_cmd(h, "set terminal png");
  gnuplot_cmd(h, "set output \"test.png\"");
  gnuplot_cmd(h, "set xlabel 'distance rho'");
  gnuplot_cmd(h, "set xlabel 'correlation'");
  gnuplot_cmd(h, "set title 'damped sine'");
  gnuplot_cmd(h, "set grid");
  gnuplot_cmd(h, "set style data lines");
  gnuplot_cmd(h, "plot \"damped_sine_data.txt\" using 1:2 lw 3 linecolor rgb \"blue\" ");
  gnuplot_cmd(h, "set terminal x11");
  gnuplot_cmd(h, "replot");
  sleep(5);
  gnuplot_cmd(h, "quit");
  gnuplot_close(h);

  gnuplot_setstyle(j, "lines");
  gnuplot_plot_xy(j, rho, c, n, "test");
  sleep(5);
  gnuplot_close(j);

  gnuplot_cmd(k, "plot \"damped_sine_data.txt\"");
  sleep(5);
  gnuplot_close(k);

  free ( rho );
  free ( c );
  return 0;
}
/******************************************************************************/

double *correlation_damped_sine ( int n, double rho[], double rho0 )

/******************************************************************************/

{
  double *c;
  int i;
  double rhohat;

  c = ( double * ) malloc ( n * sizeof ( double ) );

  for ( i = 0; i < n; i++ )
  {
    if ( rho[i] == 0.0 )
    {
      c[i] = 1.0;
    }
    else
    {
      rhohat = fabs ( rho[i] ) / rho0;
      c[i] = sin ( rhohat ) / rhohat;
    }
  }

  return c;
}
/******************************************************************************/

void correlation_plot ( int n, double rho[], double c[], char *header,
  char *title )

/******************************************************************************/

{
  char command_filename[80];
  FILE *command_unit;
  char data_filename[80];
  FILE *data_unit;
  int i;
  double rho0;

  strcpy ( data_filename, header );
  strcat ( data_filename, "_data.txt" );
  data_unit = fopen ( data_filename, "wt" );
  for ( i = 0; i < n; i++ )
  {
    fprintf ( data_unit, "%14.6g  %14.6g\n", rho[i], c[i] );
  }
  fclose ( data_unit );
  printf ( "  Created data file \"%s\".\n", data_filename );

  strcpy ( command_filename, header );
  strcat ( command_filename, "_commands.txt" );
  command_unit = fopen ( command_filename, "wt" );
  fprintf ( command_unit, "# %s\n", command_filename );
  fprintf ( command_unit, "#\n" );
  fprintf ( command_unit, "# Usage:\n" );
  fprintf ( command_unit, "#  gnuplot < %s\n", command_filename );
  fprintf ( command_unit, "#\n" );
  fprintf ( command_unit, "set term png\n" );
  fprintf ( command_unit, "set output \"%s.png\"\n", header );
  fprintf ( command_unit, "set xlabel 'Distance Rho'\n" );
  fprintf ( command_unit, "set ylabel 'Correlation C(Rho)'\n" );
  fprintf ( command_unit, "set title '%s'\n", title );
  fprintf ( command_unit, "set grid\n" );
  fprintf ( command_unit, "set style data lines\n" );
  fprintf ( command_unit, "plot \"%s\" using 1:2 lw 3 linecolor rgb \"blue\"\n", data_filename );
  fprintf ( command_unit, "quit\n" );
  fclose ( command_unit );
  printf ( "  Created command file \"%s\"\n", command_filename );

  return;
}
/******************************************************************************/

double *r8vec_linspace_new ( int n, double a, double b )

/******************************************************************************/
{
  int i;
  double *x;

  x = ( double * ) malloc ( n * sizeof ( double ) );

  if ( n == 1 )
  {
    x[0] = ( a + b ) / 2.0;
  }
  else
  {
    for ( i = 0; i < n; i++ )
    {
      x[i] = ( ( double ) ( n - 1 - i ) * a
             + ( double ) (         i ) * b )
             / ( double ) ( n - 1     );
    }
  }
  return x;
}
