/**
* @file main.c
* @author wlt
* @date 2025-11-10
* @brief Main function
* credit to https://github.com/microchip-pic-avr-examples/avr128da48-usart-example
*/

#ifndef F_CPU
#define F_CPU 4000000UL
#endif
#define F_SAMPLE_BIT 16



#include <avr/io.h>
#include <util/delay.h>
#include <string.h>


// 64*4 000 000/16 * 9600 + 0.5 = 1667.17
#define USART1_BAUD_RATE(BAUD_RATE)     ((float)(64 * F_CPU / (F_SAMPLE_BIT * (float)BAUD_RATE)) + 0.5)



void USART1_init(void);
void USART1_sendChar(char c);
void USART1_sendString(char *str);



void USART1_init(void)
{
    PORTC.DIRSET = PIN0_bm;                             /* set pin 0 of PORT C (TXd) as output*/
    PORTC.DIRCLR = PIN1_bm;                             /* set pin 1 of PORT C (RXd) as input*/
    
    USART1.BAUD = (uint16_t)(USART1_BAUD_RATE(9600));   /* set the baud rate*/
    
    USART1.CTRLC = USART_CHSIZE_0_bm
                 | USART_CHSIZE_1_bm;                    /* set the data format to 8-bit*/
                 
    USART1.CTRLB |= USART_TXEN_bm;                      /* enable transmitter*/
}

void USART1_sendChar(char c)
{
    while(!(USART1.STATUS & USART_DREIF_bm))
    {
        ;
    }
    
    USART1.TXDATAL = c;
}

void USART1_sendString(char *str)
{
    for(size_t i = 0; i < strlen(str); i++)    
    {        
        USART1_sendChar(str[i]);    
    }
}

char a[10] = {'1','2','3','4','5','6','7','8','9'};

int main(void)
{
    USART1_init();
    
    while (1)
    {
        for (int i = 0; i <= 9; i++) {
            USART1_sendChar(a[i]);
            _delay_ms(1000);
        }
    }
}

