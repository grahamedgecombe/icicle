from nmigen.hdl.rec import *

WISHBONE_LAYOUT = [
    ("adr",   30, DIR_FANOUT),
    ("dat_w", 32, DIR_FANOUT),
    ("dat_r", 32, DIR_FANIN),
    ("sel",    4, DIR_FANOUT),
    ("cyc",    1, DIR_FANOUT),
    ("stb",    1, DIR_FANOUT),
    ("we",     1, DIR_FANOUT),
    ("ack",    1, DIR_FANIN),
    ("err",    1, DIR_FANIN)
]
