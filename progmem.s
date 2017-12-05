    li t1, 7
    li t2, 3
    li t3, 0

# t3 = t1 * t2
mul:
    beqz t1, mul_done
    andi t4, t1, 1
    beqz t4, mul_even
    add t3, t3, t2
mul_even:
    srli t1, t1, 1
    slli t2, t2, 1
    j mul

# display results on the LEDs
mul_done:
    mv t6, t3
    j .
