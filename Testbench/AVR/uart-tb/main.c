/**
* @file main.c
* @author wlt
* @date 2025-11-10
* @brief Main function
*/
#include <avr/io.h>
#include <util/delay.h>


#ifndef F_CPU
#define F_CPU 4000000UL
#endif



int main(){

    //USART0.CTRLB = (1<<7)|(1<<6);

    //Add your code here and press Ctrl + Shift + B to build

    //BLINK
    PORTB.DIRSET = PIN3_bm;

    while (1) {
        PORTB.OUTTGL = PIN3_bm;
        _delay_ms(250);
    }
}


