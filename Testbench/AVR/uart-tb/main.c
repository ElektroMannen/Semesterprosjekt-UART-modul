
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



/*
* Parameters used for defining testbench duration
*/
#define N 1024      // Nnumber of sent bytes
#define RECV_LEN 8  // Bit size (8 bit in this case)


static FILE usart_stream = FDEV_SETUP_STREAM(usart3_print_char, NULL, _FDEV_SETUP_WRITE);



int main(void)
{
    // Setup communication link with PC
    usart3_init(9600);
    stdout = &usart_stream;
    
    
    // Always start testbench with 9600 bps
    usart0_init(9600);  // TX
    usart1_init(9600);  // RX
    TCA0_init();             // Timer setup
    //PORT_init();
    init_lfsr();             // Initialize random number gen
    
    
    
    char readchar;
    uint8_t xor_check;

    // Enable timer interrupts
    sei();
    


    while (1) {
        uint16_t bit_error_count = 0;
        
        
        //usart0_send_char(0xFF);
        _delay_ms(10);
        

        uint32_t t0 = tca0_ms(); // Initialize timer
        for (int i = 0; i < N; i++) {

            uint8_t random_number = rng_u8();
            usart0_send_char(random_number);
            readchar = usart1_read_char();
            
            // a^b reveals flipped (error) bits per sent byte
            xor_check = random_number ^ readchar;
            
            // If xor = 0 perform counting of flipped bits 
            if (xor_check != 0) {

                // Check each received bit
                for (int j = 0; j < RECV_LEN; j++){
                    if (xor_check >> j & 1) {
                        bit_error_count++;
                    }
                }
            }
        }

        uint32_t t1 = tca0_ms(); // End timer
        uint32_t send_time = t1 - t0; // Elapsed time for one round
        
        /*
        * Send stats for analysis
        */
        printf("\r\nSend_time:%u\r\nBit error:%u\r\n",
            (unsigned)send_time,
            (unsigned)bit_error_count);


        _delay_ms(1000); // Wait 1s before next round
    }
}
