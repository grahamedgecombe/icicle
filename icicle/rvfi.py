from nmigen.hdl.rec import *

RVFI_LAYOUT = [
    # instruction metadata
    ("valid",      1, DIR_FANOUT),
    ("order",     64, DIR_FANOUT),
    ("insn",      32, DIR_FANOUT),
    ("trap",       1, DIR_FANOUT),
    ("halt",       1, DIR_FANOUT),
    ("intr",       1, DIR_FANOUT),
    ("mode",       2, DIR_FANOUT),
    ("ixl",        2, DIR_FANOUT),

    # integer register read/write
    ("rs1_addr",   5, DIR_FANOUT),
    ("rs2_addr",   5, DIR_FANOUT),
    ("rs1_rdata", 32, DIR_FANOUT),
    ("rs2_rdata", 32, DIR_FANOUT),
    ("rd_addr",    5, DIR_FANOUT),
    ("rd_wdata",  32, DIR_FANOUT),

    # program counter
    ("pc_rdata",  32, DIR_FANOUT),
    ("pc_wdata",  32, DIR_FANOUT),

    # memory access
    ("mem_addr",  32, DIR_FANOUT),
    ("mem_rmask",  4, DIR_FANOUT),
    ("mem_wmask",  4, DIR_FANOUT),
    ("mem_rdata", 32, DIR_FANOUT),
    ("mem_wdata", 32, DIR_FANOUT)
]


class RVFI(Record):
    def __init__(self):
        super().__init__(RVFI_LAYOUT, name="rvfi")

        # adjust the flattened field names for RVFI compliance
        for (name, field) in self.fields.items():
            field.name = "rvfi_{}".format(name)
