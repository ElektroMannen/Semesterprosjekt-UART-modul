#ifndef USART1_H
#define USART1_H

#include <stdint.h>
#include <avr/io.h>
#include <stdint.h>

void usart1_init(uint32_t baud);
void usart1_set_parity(USART_PMODE_t mode);
uint8_t usart1_read_char(void);

#endif

