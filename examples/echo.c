#include <stdint.h>

static volatile uint8_t *const uart_status = (volatile uint8_t *) 0x80000006;
static volatile uint8_t *const uart_data   = (volatile uint8_t *) 0x80000007;

static const uint8_t UART_STATUS_RX_RDY = 0x1;
static const uint8_t UART_STATUS_TX_RDY = 0x2;

int main() {
    for (;;) {
        while (!(*uart_status & UART_STATUS_RX_RDY));
        uint8_t c = *uart_data;

        while (!(*uart_status & UART_STATUS_TX_RDY));
        *uart_data = c;
    }

    return 0;
}
