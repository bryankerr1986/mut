transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/uart_rx.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/uart_tx.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/reg_map_pkg.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/imp/quartus/altera_fifo.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/imp/quartus/uart_fifo.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/uart_ctrl.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/reg_map.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/spi_if_blk.vhd}
vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/src/maps_top.vhd}

vcom -93 -work work {C:/Users/Bryan/Documents/Projects/VHDL/maps/imp/quartus/../../sim/tb_src/maps_top_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  maps_top_tb

add wave *
view structure
view signals
run -all
