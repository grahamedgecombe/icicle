#include <stdint.h>

#define LEDS        *((volatile uint32_t *) 0x00010000)
#define UART_BAUD   *((volatile uint32_t *) 0x00020000)
#define UART_STATUS *((volatile uint32_t *) 0x00020004)
#define UART_DATA   *((volatile  int32_t *) 0x00020008)

int main() {
    UART_BAUD = 36000000 / 9600;

    for (;;) {
        int32_t c;
        do {
            c = UART_DATA;
        } while (c < 0);

        UART_DATA = c;
        LEDS = c;
    }
}
