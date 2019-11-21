from icicle.adder import Adder, BlackBoxAdder
from icicle.alu import SrcMux
from icicle.logic import Logic
from icicle.pipeline import Stage
from icicle.pipeline_regs import DX_LAYOUT, XM_LAYOUT
from icicle.shift import BarrelShifter


class Execute(Stage):
    def __init__(self, rvfi_blackbox_alu=False):
        super().__init__(rdata_layout=DX_LAYOUT, wdata_layout=XM_LAYOUT)
        self.rvfi_blackbox_alu = rvfi_blackbox_alu

    def elaborate(self, platform):
        m = super().elaborate(platform)

        src_mux = m.submodules.src_mux = SrcMux()
        m.d.comb += [
            src_mux.a_src.eq(self.rdata.a_src),
            src_mux.b_src.eq(self.rdata.b_src),
            src_mux.rs1_rdata.eq(self.rdata.rs1_rdata),
            src_mux.rs2_rdata.eq(self.rdata.rs2_rdata),
            src_mux.imm.eq(self.rdata.imm)
        ]

        add = m.submodules.add = BlackBoxAdder() if self.rvfi_blackbox_alu else Adder()
        m.d.comb += [
            add.sub.eq(self.rdata.add_sub),
            add.signed_compare.eq(self.rdata.add_signed_compare),
            add.a.eq(src_mux.a),
            add.b.eq(src_mux.b)
        ]

        logic = m.submodules.logic = Logic()
        m.d.comb += [
            logic.op.eq(self.rdata.logic_op),
            logic.a.eq(self.rdata.rs1_rdata),
            logic.b.eq(src_mux.b)
        ]

        shift = m.submodules.shift = BarrelShifter()
        m.d.comb += [
            shift.right.eq(self.rdata.shift_right),
            shift.arithmetic.eq(self.rdata.shift_arithmetic),
            shift.a.eq(self.rdata.rs1_rdata),
            shift.shamt.eq(src_mux.b)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.wdata.add_result.eq(add.result),
                self.wdata.add_carry.eq(add.carry),
                self.wdata.logic_result.eq(logic.result),
                self.wdata.shift_result.eq(shift.result)
            ]

        return m
