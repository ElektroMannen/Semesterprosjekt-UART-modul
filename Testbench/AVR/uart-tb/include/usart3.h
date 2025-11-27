#ifndef USART3_H
#define USART3_H

#include <avr/io.h>
#include <stdio.h>




void usart3_init(uint32_t baud);
void usart3_send_char(char c);
void usart3_send_string(const char *s);
int usart3_print_char(char c, FILE *stream);



#endif
