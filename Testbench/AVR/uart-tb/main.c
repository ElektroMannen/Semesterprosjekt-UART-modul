
#ifndef F_CPU
#define F_CPU 4000000UL
#endif

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

// USARTs
#include "usart0.h"
#include "usart1.h"
#include "usart3.h"


#include "timer0.h"
#include "rng.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>



static FILE usart_stream = FDEV_SETUP_STREAM(usart3_print_char, NULL, _FDEV_SETUP_WRITE);



int main(void)
{
    usart3_init(9600);
    stdout = &usart_stream;
    
    
    usart0_init(9600);  // TX
    usart1_init(9600);  // RX
    TCA0_init();             // Timer setup
    //PORT_init();
    init_lfsr();             // Initialize random number gen
    
    
    
    char readchar;
    uint8_t xor_check;


    sei();
    

    while (1) {
        uint16_t bit_error_count = 0;
        
        
        //usart0_send_char(0xFF);
        _delay_ms(10);
        
        
        
        
        uint32_t t0 = tca0_ms();
        for (int i = 0; i < 100; i++) {
            uint8_t random_number = rng_u8();
            usart0_send_char(random_number);
            readchar = usart1_read_char();
            xor_check = random_number ^ readchar;
            if (xor_check != 0) {
                bit_error_count++;
            }
        }

        uint32_t t1 = tca0_ms(); // time tb-event
        
        
        uint32_t send_time = t1 - t0;
        
        printf("\r\nSend_time:%u\r\nBit error:%u\r\n",
            (unsigned)send_time,
            (unsigned)bit_error_count);

        _delay_ms(1000);
    }
}
