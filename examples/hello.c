#include <stdint.h>

static volatile uint8_t *const uart_status = (volatile uint8_t *) 0x80000006;
static volatile uint8_t *const uart_data   = (volatile uint8_t *) 0x80000007;

static const uint8_t UART_STATUS_TX_RDY = 0x2;

static void uart_puts(const char *str) {
    char c;
    while ((c = *str++)) {
        while (!(*uart_status & UART_STATUS_TX_RDY));
        *uart_data = c;
    }
}

int main() {
    for (;;) {
        uart_puts("Hello, world!\r\n");
    }

    return 0;
}
