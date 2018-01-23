yosys -import
read_verilog -D$::env(IC) -noautowire -sv top.sv
puts "device is $::env(IC)" ; 

#yosys proc
procs
# the above are the same, see: http://www.clifford.at/yosys/cmd_tcl.html

opt -full
alumacc
share -aggressive
synth_ice40 -abc2 -top top -blif top.blif
