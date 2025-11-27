#ifndef TIMER0_H
#define TIMER0_H
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>


volatile uint16_t second_counter;

void TCA0_init(void);
uint16_t tca0_timestamp(void);
uint32_t tca0_ms(void);
void PORT_init(void);

#endif

