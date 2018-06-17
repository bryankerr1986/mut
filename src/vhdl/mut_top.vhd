--------------------------------------------------------------------------------
-- TITLE: MAX1000 UART Transciever (MUT)
--
-- FILENAME: mut_top.vhd
--
-- AUTHOR: Bryan Kerr
--
-- REVISION: 1.1
-- DATE: 06/01/2018
--
-- DESCRIPTION:
-- 
-- MUT is an interface to the peripherals on the MAX1000 development board.
-- PC access to these peripherals is controlled by the MUT via a UART interface.
--  
--  
--------------------------------------------------------------------------------
-- REVISION HISTORY (MANUAL):
-- 06/01/2018 BEK - Initial coding
--
--------------------------------------------------------------------------------
-- Library declarations
--------------------------------------------------------------------------------
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.reg_map_pkg.all;

entity maps_top is
   port
   (
   -- Clocks and Resets
   CLK_12   : in  std_logic; -- 12 MHz clock
   CLK_SPI  : out std_logic; --  1 MHz clock
   RST_N    : in  std_logic; -- Active low asynchronous reset
   -- SPI RAD ports --
   SPI_MISO    : in  std_logic; -- Master (MUT) In,  Slave (Accelerometer) Out
   SPI_MOSI    : out std_logic; -- Master (MUT) Out, Slave (Accelerometer) In
   SPI_CS_N    : out std_logic; -- Slave (Accelerometer)  Chip Select
   -- UART ports --
   TXD      : in  std_logic; -- FT2232H transmitter output
   RXD      : out std_logic; -- FT2232H receiver input
   RTS_N    : in  std_logic; -- FT2232H ready to send handshake output
   CTS_N    : out std_logic; -- FT2232H clear to send handshake input
   DTR_N    : in  std_logic; -- FT2232H data transmit ready modem signaling line
   DSR_N    : out std_logic; -- FT2232H data set ready modem signaling line
   -- LED Outputs --
   LED1     : out std_logic; -- LED1 output
   LED2     : out std_logic; -- LED2 output
   LED3     : out std_logic; -- LED3 output
   LED4     : out std_logic; -- LED4 output
   LED5     : out std_logic; -- LED5 output
   LED6     : out std_logic; -- LED6 output
   LED7     : out std_logic; -- LED7 output
   LED8     : out std_logic  -- LED8 output
   );
end maps_top;

architecture rtl of maps_top is
--------------------------------------------------------------------------------
-- Component declarations
--------------------------------------------------------------------------------

component uart_ctrl
   port
   (
   -- Clocks and Resets --
   CLK_12      : in  std_logic; -- 12 MHz clock
   RST_N       : in  std_logic; -- Global reset
   -- UART ports --
   TXD      : in  std_logic; -- FT2232H transmitter output
   RXD      : out std_logic; -- FT2232H receiver input
   RTS_N    : in  std_logic; -- FT2232H ready to send handshake output
   CTS_N    : out std_logic; -- FT2232H clear to send handshake input
   DTR_N    : in  std_logic; -- FT2232H data transmit ready modem signaling line
   DSR_N    : out std_logic; -- FT2232H data set ready modem signaling line
   -- Register ports --
   REG_WR_ENB        : out std_logic;
   REG_ADDR          : out std_logic_vector(C_MAX_ADDRESS_SIZE-1 downto 0);
   REG_DAT_IN        : out std_logic_vector(C_MAX_REG_SIZE-1     downto 0);
   REG_DAT_OUT       : in  std_logic_vector(C_MAX_REG_SIZE-1     downto 0);
   REG_RD_VLD        : in  std_logic;
   UART_FIFO_DATA    : out std_logic_Vector(7 downto 0)
   );
end component;

component reg_map
   port
   (
   -- Clocks and Resets -- 
   CLK_12            : in  std_logic; -- 12 MHz clock
   RST_N             : in  std_logic; -- Active low asynchronous reset
   -- Register ports -- 
   REG_WR_ENB        : in  std_logic;
   REG_ADDR          : in  std_logic_vector(C_MAX_ADDRESS_SIZE-1 downto 0);
   REG_DAT_IN        : in  std_logic_vector(C_MAX_REG_SIZE-1     downto 0);
   REG_DAT_OUT       : out std_logic_vector(C_MAX_REG_SIZE-1     downto 0);
   REG_RD_VLD        : out std_logic;
   -- FROM RAD --
   ACC_X_DATA        : in  std_logic_Vector(7 downto 0);
   ACC_Y_DATA        : in  std_logic_Vector(7 downto 0);
   ACC_Z_DATA        : in  std_logic_Vector(7 downto 0)
   );
end component;

component rad
   port
   (
   -- Clocks and Resets -- 
   CLK_12        : in  std_logic; -- 12 MHz clock
   CLK_SPI       : out std_logic; --  1 MHz clock
   RST_N         : in  std_logic; -- Active low asynchronous reset
   -- SPI RAD ports --
   SPI_MISO      : in  std_logic; -- Master (MUT) In,  Slave (Accelerometer) Out
   SPI_MOSI      : out std_logic; -- Master (MUT) Out, Slave (Accelerometer) In
   SPI_CS_N      : out std_logic; -- Slave (Accelerometer)  Chip Select
   -- Accelerometer Data --
   ACC_X_DATA    : out std_logic_Vector(7 downto 0);
   ACC_Y_DATA    : out std_logic_Vector(7 downto 0);
   ACC_Z_DATA    : out std_logic_Vector(7 downto 0)
   );
end component;

component led_blink
   port
   (
   -- Clocks and Resets -- 
   CLK_12   : in  std_logic; -- 12 MHz clock
   RST_N    : in  std_logic; -- Active low asynchronous reset
   -- LED Outputs --
   LED1     : out std_logic; -- LED1 output
   LED2     : out std_logic; -- LED2 output
   LED3     : out std_logic; -- LED3 output
   LED4     : out std_logic; -- LED4 output
   LED5     : out std_logic; -- LED5 output
   LED6     : out std_logic; -- LED6 output
   LED7     : out std_logic; -- LED7 output
   LED8     : out std_logic  -- LED8 output
   );
end component;

--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
-- RAD signals
signal acc_x_data : std_logic_vector(7 downto 0);
signal acc_y_data : std_logic_vector(7 downto 0);
signal acc_z_data : std_logic_vector(7 downto 0);
-- UART signals
signal reg_dat_out       : std_logic_vector(C_MAX_REG_SIZE-1 downto 0);
signal reg_rd_vld        : std_logic;
signal uart_reg_wr_enb   : std_logic;
signal uart_reg_addr     : std_logic_vector(C_MAX_ADDRESS_SIZE-1 downto 0);
signal uart_reg_dat_in   : std_logic_vector(C_MAX_REG_SIZE-1 downto 0);
   
begin
--------------------------------------------------------------------------------
-- Instantiations
--------------------------------------------------------------------------------
   u_uart_ctrl : uart_ctrl
      port map
      (
      CLK_12         => CLK_12               ,
      RST_N          => RST_N                ,
      TXD            => TXD                  ,
      RXD            => RXD                  ,
      RTS_N          => RTS_N                ,
      CTS_N          => CTS_N                ,
      DTR_N          => DTR_N                ,
      DSR_N          => DSR_N                ,
      REG_WR_ENB     => uart_reg_wr_enb      ,
      REG_ADDR       => uart_reg_addr        ,
      REG_DAT_IN     => uart_reg_dat_in      ,
      REG_DAT_OUT    => reg_dat_out          ,
      REG_RD_VLD     => reg_rd_vld           ,
      UART_FIFO_DATA => open                 
      );
   
   -- Registers
   u_reg_map : reg_map
      port map
      (
      CLK_12            => CLK_12            ,
      RST_N             => RST_N             ,
      REG_WR_ENB        => uart_reg_wr_enb   ,
      REG_ADDR          => uart_reg_addr     ,
      REG_DAT_IN        => uart_reg_dat_in   ,
      REG_DAT_OUT       => reg_dat_out       ,
      REG_RD_VLD        => reg_rd_vld        ,
      ACC_X_DATA        => acc_x_data        ,
      ACC_Y_DATA        => acc_y_data        ,
      ACC_Z_DATA        => acc_z_data        
      );
   
   u_rad : rad
      port map
      (
      CLK_12       => CLK_12            ,
      CLK_SPI      => CLK_SPI           ,
      RST_N        => RST_N             ,
      SPI_MISO     => SPI_MISO          ,
      SPI_MOSI     => SPI_MOSI          ,
      SPI_CS_N     => SPI_CS_N          ,
      ACC_X_DATA   => acc_x_data        ,
      ACC_Y_DATA   => acc_y_data        ,
      ACC_Z_DATA   => acc_z_data        
      );
   
   u_led_blink : led_blink
      port map
      (
      CLK_12   => CLK_12            ,
      RST_N    => RST_N             ,
      LED1     => LED1              ,
      LED2     => LED2              ,
      LED3     => LED3              ,
      LED4     => LED4              ,
      LED5     => LED5              ,
      LED6     => LED6              ,
      LED7     => LED7              ,
      LED8     => LED8              
      );
   
end rtl;