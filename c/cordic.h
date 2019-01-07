#ifndef _cordic_h_
#define _cordic_h_

#include <stdint.h>

#if 0
typedef float real_t;
#else
typedef double real_t;
#endif

#define CORDIC_LUT_LENGTH	(sizeof(real_t) * 8)

real_t compute_K(const uint32_t N);

void cordic(
		const real_t angle,
		real_t * sine,
		real_t * cosine);

#endif
