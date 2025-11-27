#ifndef USART0_H
#define USART0_H

#include <avr/io.h>

void usart0_init(uint32_t baud);
void usart0_send_char(char c);
void usart0_send_string(const char *s);


#endif
