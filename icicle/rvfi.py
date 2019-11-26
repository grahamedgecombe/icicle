from nmigen import *

RVFI_LAYOUT = [
    # instruction metadata
    ("valid",      1),
    ("order",     64),
    ("insn",      32),
    ("trap",       1),
    ("halt",       1),
    ("intr",       1),
    ("mode",       2),
    ("ixl",        2),

    # integer register read/write
    ("rs1_addr",   5),
    ("rs2_addr",   5),
    ("rs1_rdata", 32),
    ("rs2_rdata", 32),
    ("rd_addr",    5),
    ("rd_wdata",  32),

    # program counter
    ("pc_rdata",  32),
    ("pc_wdata",  32),

    # memory access
    ("mem_addr",  32),
    ("mem_rmask",  4),
    ("mem_wmask",  4),
    ("mem_rdata", 32),
    ("mem_wdata", 32)
]


class RVFI(Record):
    def __init__(self):
        super().__init__(RVFI_LAYOUT, src_loc_at=1)

        # adjust the flattened field names for RVFI compliance
        for (name, field) in self.fields.items():
            field.name = "rvfi_{}".format(name)
