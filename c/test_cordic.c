#include "cordic.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#if 0
/* single-precision */
#define THRESHOLD (1e-6)
#else
/* double-precision */
#define THRESHOLD (1e-12)
#endif

#ifndef M_PI
#define M_PI (3.14159265358979323846)
#endif

#define STEPS (180)

int main() {
  real_t angle = -(M_PI / 2);
  real_t angles[STEPS];
  real_t sine[STEPS], cosine[STEPS], ref_s[STEPS], ref_c[STEPS];
  const real_t step = (M_PI) / STEPS;
  int i = 0, errors = 0;

  /* Prepare */
  for (i = 0; i < STEPS; i++) {
    angles[i] = angle;
    angle += step;
  }

  /* Compute */
  for (i = 0; i < STEPS; i++) {
    cordic(angles[i], &sine[i], &cosine[i]);
    ref_s[i] = sin(angles[i]);
    ref_c[i] = cos(angles[i]);
  }

  /* Check output */
  for (i = 0; i < STEPS; i++) {
#if 0
        printf("s = %e, r_s = %e, c = %e, r_c = %e\n",
            sine[i], ref_s[i], cosine[i], ref_c[i]);
#endif
    if (fabs(ref_s[i] - sine[i]) > THRESHOLD)
      errors++;
    if (fabs(ref_c[i] - cosine[i]) > THRESHOLD)
      errors++;
  }

  printf("Total number of errors = %d\n", errors);
  return (errors == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
}
