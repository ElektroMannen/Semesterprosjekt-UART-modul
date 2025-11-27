/*

Thanks to 

https://www.analog.com/en/resources/design-notes/random-number-generation-using-lfsr.html

, for useful article on generating pseudo random numbers in C.

*/


#include "rng.h"
#include <avr/io.h>
#include <stdint.h>




static uint32_t lfsr32;

/*
* Initiate RNG
*/
void init_lfsr(void) {
    lfsr32 = 0xB4BCD35C; // period = 4,294,967,29
}

/*
* Pseudo random number generator
*/
uint32_t shift_lfsr(void) {
    uint32_t x = lfsr32;
    if (lfsr32 & 1) {
        lfsr32 = (lfsr32 >> 1) ^ 0xB4BCD35C;
    } else {
        lfsr32 >>= 1;
    }
    lfsr32 = x;
    return x;
}


/*
* Convert to 8bit value again
*/
uint8_t rng_u8(void) {
    return (uint8_t)shift_lfsr();
}
