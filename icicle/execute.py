from icicle.adder import Adder, BlackBoxAdder
from icicle.alu import OperandMux
from icicle.branch import BranchTargetMux
from icicle.logic import Logic
from icicle.pipeline import Stage
from icicle.pipeline_regs import DX_LAYOUT, XM_LAYOUT
from icicle.shift import BarrelShifter


class Execute(Stage):
    def __init__(self, rvfi_blackbox_alu=False):
        super().__init__(i_layout=DX_LAYOUT, o_layout=XM_LAYOUT)
        self.rvfi_blackbox_alu = rvfi_blackbox_alu

    def elaborate_stage(self, m, platform):
        operand_mux = m.submodules.operand_mux = OperandMux()
        m.d.comb += [
            operand_mux.a_sel.eq(self.i.a_sel),
            operand_mux.b_sel.eq(self.i.b_sel),
            operand_mux.pc_rdata.eq(self.i.pc_rdata),
            operand_mux.rs1_rdata.eq(self.i.rs1_rdata),
            operand_mux.rs2_rdata.eq(self.i.rs2_rdata),
            operand_mux.imm.eq(self.i.imm)
        ]

        add = m.submodules.add = BlackBoxAdder() if self.rvfi_blackbox_alu else Adder()
        m.d.comb += [
            add.sub.eq(self.i.add_sub),
            add.signed_compare.eq(self.i.add_signed_compare),
            add.a.eq(operand_mux.a),
            add.b.eq(operand_mux.b)
        ]

        logic = m.submodules.logic = Logic()
        m.d.comb += [
            logic.op.eq(self.i.logic_op),
            logic.a.eq(self.i.rs1_rdata),
            logic.b.eq(operand_mux.b)
        ]

        shift = m.submodules.shift = BarrelShifter()
        m.d.comb += [
            shift.right.eq(self.i.shift_direction),
            shift.arithmetic.eq(self.i.shift_arithmetic),
            shift.a.eq(self.i.rs1_rdata),
            shift.shamt.eq(operand_mux.b)
        ]

        branch_target_mux = m.submodules.branch_target_mux = BranchTargetMux()
        m.d.comb += [
            branch_target_mux.sel.eq(self.i.branch_target_sel),
            branch_target_mux.pc_rdata.eq(self.i.pc_rdata),
            branch_target_mux.rs1_rdata.eq(self.i.rs1_rdata),
            branch_target_mux.imm.eq(self.i.imm)
        ]

        with m.If(~self.stall):
            m.d.sync += [
                self.o.add_result.eq(add.result),
                self.o.add_carry.eq(add.carry),
                self.o.logic_result.eq(logic.result),
                self.o.shift_result.eq(shift.result),
                self.o.branch_target.eq(branch_target_mux.target),
                self.o.branch_misaligned.eq(branch_target_mux.misaligned)
            ]
