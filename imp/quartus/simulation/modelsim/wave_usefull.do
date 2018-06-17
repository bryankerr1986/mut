onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/CLK_12
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/CLK_SPI
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/RST_N
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/SPI_MISO
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/SPI_MOSI
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/SPI_CS_N
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED1
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED2
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED3
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED4
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED5
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED6
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED7
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/LED8
add wave -noupdate -radix hexadecimal -radixshowbase 1 /maps_top_tb/RD_FIFO
add wave -noupdate /maps_top_tb/uut/feat_fifo_dat_out
add wave -noupdate -divider {SPI IF}
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/spi_cs
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/spi_ns
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/pos_clk_spi
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/neg_spi_cs
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/pos_spi_cs
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/i_clk_spi
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/i_spi_cs_n
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/i_spi_mosi
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/data_in
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/instr_reg
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/feature_rx_cmd
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/reg_wr_cmd
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/invld_instr
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/cnt_24
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/clr_shift_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/incr_shift_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/shift_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/clr_push_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/ld_data_out
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/data_out
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/push
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/push_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/word_sent
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/imu_pos
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/latch_imu
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/word_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/latch_word_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/latch_addr
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/decr_word_cnt
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/no_more_feats
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/ld_wr_not_rd
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/clr_wr_not_rd
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/wr_not_rd
add wave -noupdate -color Magenta -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_spi_if_blk/reg_rd_cmd
add wave -noupdate -divider REG_MAP
add wave -noupdate -color Coral -radix hexadecimal -childformat {{/maps_top_tb/uut/u_reg_map/i_registers.loopback_reg -radix hexadecimal} {/maps_top_tb/uut/u_reg_map/i_registers.feat_fifo_wd_cnt_reg -radix hexadecimal}} -radixshowbase 1 -expand -subitemconfig {/maps_top_tb/uut/u_reg_map/i_registers.loopback_reg {-color Coral -height 15 -radix hexadecimal -radixshowbase 1} /maps_top_tb/uut/u_reg_map/i_registers.feat_fifo_wd_cnt_reg {-color Coral -height 15 -radix hexadecimal -radixshowbase 1}} /maps_top_tb/uut/u_reg_map/i_registers
add wave -noupdate -color Coral -radix hexadecimal -radixshowbase 1 /maps_top_tb/uut/u_reg_map/i_reg_addr
add wave -noupdate -divider FIFO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1107655563 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 296
configure wave -valuecolwidth 304
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1687261790 ps}
