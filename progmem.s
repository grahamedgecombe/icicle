# set baud rate to 9600
    li t0, 0x00020000
    li t1, 3750
    sw t1, 0(t0)

# read char from the UART
    li t0, 0x00020008
    li t1, 0x00010000
loop:
    lw t2, 0(t0)
    bltz t2, loop

# write to the LEDs
    sw t2, 0(t0)

# echo back to the UART
    sw t2, 0(t1)
    j loop
