#ifndef RNG_H
#define RNG_H

#include <stdint.h>



void init_lfsr(void);
uint32_t shift_lfsr(void);
uint8_t rng_u8(void);



#endif