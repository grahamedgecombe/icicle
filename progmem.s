    li t0, 7
    li t1, 3
    li t2, 0

# t2 = t0 * t1
mul:
    beqz t0, mul_done
    andi t3, t0, 1
    beqz t3, mul_even
    add t2, t2, t1
mul_even:
    srli t0, t0, 1
    slli t1, t1, 1
    j mul

# display results on the LEDs
mul_done:
    li t0, 0x00010000
    sw t2, 0(t0)
    j .
