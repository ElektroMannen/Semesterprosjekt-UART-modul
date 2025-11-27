#include "usart1.h"

#ifndef F_CPU
#define F_CPU 4000000UL
#endif

#define F_SAMPLE_BIT 16
#define USART1_BAUD_REG(BAUD) ((uint16_t)((64.0 * F_CPU / (F_SAMPLE_BIT * (double)(BAUD))) + 0.5))


void usart1_init(uint32_t baud)
{
    PORTC.DIRSET = PIN0_bm;      // TX
    PORTC.DIRCLR = PIN1_bm;      // RX
    PORTC.PIN1CTRL |= PORT_PULLUPEN_bm;

    USART1.BAUD  = USART1_BAUD_REG(baud);
    USART1.CTRLC = USART_CHSIZE_8BIT_gc;
    USART1.CTRLB = USART_RXEN_bm;
}


uint8_t usart1_read_char(void) {

    while(!(USART1.STATUS & USART_RXCIF_bm)) {
        ;
    }
    
    uint8_t received_char = USART1.RXDATAL;
    return received_char;
}

void usart1_set_parity(USART_PMODE_t mode)
{
    USART1.CTRLC = (USART1.CTRLC & ~USART_PMODE_gm) | mode;
}


