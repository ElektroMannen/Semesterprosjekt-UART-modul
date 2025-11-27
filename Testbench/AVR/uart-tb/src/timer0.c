/*
* Setup timer register 
*
* Modified from microchip AVR timer examples:
*
* https://github.com/microchip-pic-avr-examples/avr64dd32-getting-started-with-tca-mplabx/blob/master/Using_Periodic_Interrupt_Mode.X/main.c
*
*/


#include "timer0.h"
#include <stdint.h>




#ifndef F_CPU
#define F_CPU 4000000UL
#endif

/*  Using default clock 4MHz, TMR_CLK = F_CPU / PRESCALER = 4MHz / 64 = 62.5 kHz */
#define PERIOD_1000_MS 62499  /* T = 1000ms, F = 62.5kHz/(62499 + 1) = 1 Hz */

volatile uint16_t second_counter;

void TCA0_init(void)
{
    /* enable overflow interrupt */
    TCA0.SINGLE.INTCTRL = TCA_SINGLE_OVF_bm;
    
    /* set Normal mode */
    TCA0.SINGLE.CTRLB = TCA_SINGLE_WGMODE_NORMAL_gc;
    
    /* disable event counting */
    TCA0.SINGLE.EVCTRL &= ~TCA_SINGLE_CNTAEI_bm;
    
    /* set the period */
    TCA0.SINGLE.PER = PERIOD_1000_MS;  
    
    TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV64_gc         /* set clock source (sys_clk/64) */
                      | TCA_SINGLE_ENABLE_bm;                /* start timer */
}

uint16_t tca0_timestamp(void) {
    return TCA0.SINGLE.CNT;
}

uint32_t tca0_ms(void) {
    return (second_counter*1000)+((1000*(uint32_t)tca0_timestamp()) / PERIOD_1000_MS);
}


ISR(TCA0_OVF_vect)
{
    /* Toggle pin 5 of PORT B */
    //PORTB.OUTTGL = PIN5_bm;

    second_counter++;
    
    /* Clear the interrupt flag */
    TCA0.SINGLE.INTFLAGS = TCA_SINGLE_OVF_bm;
}


void PORT_init(void)
{
    /* set pin 5 of PORT F as output */
    PORTB.DIRSET = PIN5_bm;
}