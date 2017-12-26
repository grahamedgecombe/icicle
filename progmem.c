#include <stdint.h>

#define LEDS        *((volatile uint32_t *) 0x00010000)
#define UART_BAUD   *((volatile uint32_t *) 0x00020000)
#define UART_STATUS *((volatile uint32_t *) 0x00020004)
#define UART_DATA   *((volatile  int32_t *) 0x00020008)

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

static void uart_puts(const char *str) {
    char c;
    while ((c = *str++)) {
        while (!(UART_STATUS & UART_STATUS_TX_READY));
        UART_DATA = c;
    }
}

int main() {
    UART_BAUD = FREQ / 9600;
    LEDS = 0xAA;

    for (;;) {
        uart_puts("Hello, world!\r\n");
    }
}
