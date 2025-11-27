#include "usart0.h"


#ifndef F_CPU
#define F_CPU 4000000UL
#endif

#define F_SAMPLE_BIT 16
#define USART0_BAUD_REG(BAUD) ((uint16_t)((64.0 * F_CPU / (F_SAMPLE_BIT * (double)(BAUD))) + 0.5))


void usart0_init(uint32_t baud)
{

    PORTMUX.USARTROUTEA =
    (PORTMUX.USARTROUTEA & ~PORTMUX_USART0_gm) | PORTMUX_USART0_ALT1_gc;

    PORTA.DIRSET = PIN4_bm;      // TX
    PORTA.DIRCLR = PIN5_bm;      // RX
    PORTA.PIN1CTRL |= PORT_PULLUPEN_bm;

    USART0.BAUD  = USART0_BAUD_REG(baud);
    USART0.CTRLC = USART_CHSIZE_8BIT_gc;
    USART0.CTRLB = USART_TXEN_bm;
}

void usart0_send_char(char c)
{
    while (!(USART0.STATUS & USART_DREIF_bm)) {;}
    USART0.TXDATAL = c;
}

void usart0_send_string(const char *s)
{
    while (*s) {
        usart0_send_char(*s++);
    }
}
