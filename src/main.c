#include "../inc/main.h"

/* Macros for blinky examples */
#define ATMEGA2560  // Uncomment for ATmega2560
// #define ATMEGA328P  // Uncomment for ATmega328P

int main(void)
{
#ifdef ATMEGA2560
    /* Blinky for ATmega2560 */
    DDRB |= (1 << PB7);
    while (1)
    {
        PORTB ^= (1 << PB7);
        _delay_ms(50);
    }
#elif defined(ATMEGA328P)
    /* Blinky for ATmega328P */
    DDRB |= (1 << PB5);
    while (1)
    {
        PORTB ^= (1 << PB5);
        _delay_ms(50);
    }
#else
    /* Loop */
    while (1)
    {
    }
    return 0;
#endif
}
