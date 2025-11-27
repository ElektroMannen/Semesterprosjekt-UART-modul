#include "usart3.h"


#ifndef F_CPU
#define F_CPU 4000000UL
#endif

#define F_SAMPLE_BIT 16
#define USART3_BAUD_REG(BAUD) ((uint16_t)((64.0 * F_CPU / (F_SAMPLE_BIT * (double)(BAUD))) + 0.5))


void usart3_init(uint32_t baud)
{
    PORTB.DIRSET = PIN0_bm;      // TX
    PORTB.DIRCLR = PIN1_bm;      // RX
    PORTB.PIN1CTRL |= PORT_PULLUPEN_bm;

    USART3.BAUD  = USART3_BAUD_REG(baud);
    USART3.CTRLC = USART_CHSIZE_8BIT_gc;
    USART3.CTRLB = USART_TXEN_bm;
}

void usart3_send_char(char c)
{
    while (!(USART3.STATUS & USART_DREIF_bm)) {;}
    USART3.TXDATAL = c;
}

void usart3_send_string(const char *s)
{
    while (*s) {
        usart3_send_char(*s++);
    }
}

int usart3_print_char(char c, FILE *stream)
{
    while (!(USART3.STATUS & USART_DREIF_bm)) {;}
    USART3.TXDATAL = c;
    return 0;
}
