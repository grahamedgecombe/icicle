#include <stdint.h>

static volatile uint8_t *const gpio_oe = (volatile uint8_t *) 0x80000000;
static volatile uint8_t *const gpio_o  = (volatile uint8_t *) 0x80000002;

int main() {
    *gpio_oe = 0x1;

    for (;;) {
        *gpio_o = ~*gpio_o;

        for (int i = 0; i < 10000; i++) {
            asm volatile ("nop");
        }
    }

    return 0;
}
