#include "../inc/main.h"

int main(void)
{
    DDRB |= (1 << PB7);
    while (1)
    {
        PORTB ^= (1 << PB7);  // Toggle PB7
        _delay_ms(100);       // Delay for 1 second
    }
    return 0;
}
