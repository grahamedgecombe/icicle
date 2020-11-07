from nmigen import *

from icicle.control import Control
from icicle.imm import ImmediateDecoder
from icicle.pipeline import Stage
from icicle.pipeline_regs import FD_LAYOUT, DX_LAYOUT
from icicle.regs import RS_PORT_LAYOUT


class Decode(Stage):
    def __init__(self):
        super().__init__(rdata_layout=FD_LAYOUT, wdata_layout=DX_LAYOUT)
        self.rs1_port = Record(RS_PORT_LAYOUT)
        self.rs2_port = Record(RS_PORT_LAYOUT)
        self.rs1_ren = Signal()
        self.rs2_ren = Signal()

    def elaborate_stage(self, m, platform):
        control = m.submodules.control = Control()
        m.d.comb += control.insn.eq(self.rdata.insn)
        self.trap_on(control.illegal)

        imm_decoder = m.submodules.imm_decoder = ImmediateDecoder()
        m.d.comb += [
            imm_decoder.insn.eq(self.rdata.insn),
            imm_decoder.fmt.eq(control.fmt)
        ]

        m.d.comb += [
            self.rs1_port.en.eq(~self.stall),
            self.rs1_port.addr.eq(control.rs1),
            self.wdata.rs1_rdata.eq(self.rs1_port.data),

            self.rs2_port.en.eq(~self.stall),
            self.rs2_port.addr.eq(control.rs2),
            self.wdata.rs2_rdata.eq(self.rs2_port.data),

            self.rs1_ren.eq(control.rs1_ren),
            self.rs2_ren.eq(control.rs2_ren)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.rd.eq(control.rd),
                self.wdata.rd_wen.eq(control.rd_wen),
                self.wdata.rs1.eq(control.rs1),
                self.wdata.rs1_ren.eq(control.rs1_ren),
                self.wdata.rs2.eq(control.rs2),
                self.wdata.rs2_ren.eq(control.rs2_ren),
                self.wdata.imm.eq(imm_decoder.imm),
                self.wdata.a_sel.eq(control.a_sel),
                self.wdata.b_sel.eq(control.b_sel),
                self.wdata.add_sub.eq(control.add_sub),
                self.wdata.add_signed_compare.eq(control.add_signed_compare),
                self.wdata.logic_op.eq(control.logic_op),
                self.wdata.shift_direction.eq(control.shift_right),
                self.wdata.shift_arithmetic.eq(control.shift_arithmetic),
                self.wdata.result_sel.eq(control.result_sel),
                self.wdata.branch_target_sel.eq(control.branch_target_sel),
                self.wdata.branch_op.eq(control.branch_op),
                self.wdata.mem_load.eq(control.mem_load),
                self.wdata.mem_store.eq(control.mem_store),
                self.wdata.mem_width.eq(control.mem_width),
                self.wdata.mem_unsigned.eq(control.mem_unsigned),
                self.wdata.wdata_sel.eq(control.wdata_sel)
            ]
