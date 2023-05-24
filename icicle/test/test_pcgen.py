from unittest import TestCase

from amaranth import *
from amaranth.sim import Simulator, Settle

from icicle.pcgen import PCGen
from icicle.pipeline import State


class PCGenTestCase(TestCase):
    def test_basic(self):
        m = PCGen(reset_vector=0x00100000)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.o.state), State.BUBBLE.value)
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100000)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100004)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100008)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_stall(self):
        m = PCGen(reset_vector=0x00100000)

        stall = Signal()
        m.stall_on(stall)

        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.o.state), State.BUBBLE.value)
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100000)
            yield stall.eq(1)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.BUBBLE.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100000)
            yield stall.eq(0)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100004)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_branch(self):
        m = PCGen(reset_vector=0x00100000)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.o.state), State.BUBBLE.value)
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100000)
            yield m.branch_taken.eq(1)
            yield m.branch_target.eq(0x00200000)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00200000)
            yield m.branch_taken.eq(0)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00200004)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()

    def test_trap(self):
        m = PCGen(reset_vector=0x00100000, trap_vector=0x00200000)
        sim = Simulator(m)
        def process():
            self.assertEqual((yield m.o.state), State.BUBBLE.value)
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00100000)
            yield m.trap_raised.eq(1)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00200000)
            yield m.trap_raised.eq(0)
            yield
            yield Settle()
            self.assertEqual((yield m.o.state), State.VALID.value)
            self.assertEqual((yield m.o.pc_rdata), 0x00200004)
        sim.add_clock(period=1e-6)
        sim.add_sync_process(process)
        sim.run()
