from amaranth import *

from icicle.control import Control
from icicle.imm import ImmediateDecoder
from icicle.pipeline import Stage
from icicle.pipeline_regs import FD_LAYOUT, DX_LAYOUT
from icicle.regs import RS_PORT_LAYOUT


class Decode(Stage):
    def __init__(self):
        super().__init__(i_layout=FD_LAYOUT, o_layout=DX_LAYOUT)
        self.rs1_port = Record(RS_PORT_LAYOUT)
        self.rs2_port = Record(RS_PORT_LAYOUT)
        self.rs1_ren = Signal()
        self.rs2_ren = Signal()

    def elaborate_stage(self, m, platform):
        control = m.submodules.control = Control()
        m.d.comb += control.insn.eq(self.i.insn)
        self.trap_on(control.illegal)

        imm_decoder = m.submodules.imm_decoder = ImmediateDecoder()
        m.d.comb += [
            imm_decoder.insn.eq(self.i.insn),
            imm_decoder.fmt.eq(control.fmt)
        ]

        m.d.comb += [
            self.rs1_port.en.eq(~self.stall),
            self.rs1_port.addr.eq(control.rs1),
            self.o.rs1_rdata.eq(self.rs1_port.data),

            self.rs2_port.en.eq(~self.stall),
            self.rs2_port.addr.eq(control.rs2),
            self.o.rs2_rdata.eq(self.rs2_port.data),

            self.rs1_ren.eq(control.rs1_ren),
            self.rs2_ren.eq(control.rs2_ren)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.o.rd.eq(control.rd),
                self.o.rd_wen.eq(control.rd_wen),
                self.o.rs1.eq(control.rs1),
                self.o.rs1_ren.eq(control.rs1_ren),
                self.o.rs2.eq(control.rs2),
                self.o.rs2_ren.eq(control.rs2_ren),
                self.o.imm.eq(imm_decoder.imm),
                self.o.a_sel.eq(control.a_sel),
                self.o.b_sel.eq(control.b_sel),
                self.o.add_sub.eq(control.add_sub),
                self.o.add_signed_compare.eq(control.add_signed_compare),
                self.o.logic_op.eq(control.logic_op),
                self.o.shift_direction.eq(control.shift_right),
                self.o.shift_arithmetic.eq(control.shift_arithmetic),
                self.o.result_sel.eq(control.result_sel),
                self.o.branch_target_sel.eq(control.branch_target_sel),
                self.o.branch_op.eq(control.branch_op),
                self.o.mem_load.eq(control.mem_load),
                self.o.mem_store.eq(control.mem_store),
                self.o.mem_width.eq(control.mem_width),
                self.o.mem_unsigned.eq(control.mem_unsigned),
                self.o.wdata_sel.eq(control.wdata_sel)
            ]
