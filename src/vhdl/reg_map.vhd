--------------------------------------------------------------------------------
--  TITLE: Register Map
--
--  FILENAME: reg_map.vhd
--
--  AUTHOR: Bryan Kerr
--
--  REVISION:
--  DATE:
--
--  DESCRIPTION:
--  
--  Internal Registers:
--  Address 1 := Loopback register
--  Address 2 := Accelerometer X data register
--  Address 3 := Accelerometer Y data register
--  Address 4 := Accelerometer Z data register
--  
--  
--------------------------------------------------------------------------------
--  REVISION HISTORY (MANUAL):
--  06/01/2018 BEK - Initial coding
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

entity reg_map is
   port
   (
   -- Clocks and Resets -- 
   CLK_12            : in  std_logic; -- 12 MHz clock
   RST_N             : in  std_logic; -- Active low asynchronous reset
   -- Register ports -- 
   REG_WR_ENB        : in  std_logic; -- Write enable
   REG_ADDR          : in  std_logic_vector(C_MAX_ADDRESS_SIZE-1 downto 0);
   REG_DAT_IN        : in  std_logic_vector(C_MAX_REG_SIZE-1 downto 0);
   REG_DAT_OUT       : out std_logic_vector(C_MAX_REG_SIZE-1 downto 0);
   REG_RD_VLD        : out std_logic;
   -- FROM RAD --
   ACC_X_DATA        : in  std_logic_Vector(7 downto 0);
   ACC_Y_DATA        : in  std_logic_Vector(7 downto 0);
   ACC_Z_DATA        : in  std_logic_Vector(7 downto 0)
   );
end reg_map;

architecture rtl of reg_map is
--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
signal i_registers      : reg_record;
signal i_reg_addr       : natural;

begin

i_reg_addr <= conv_integer(REG_ADDR);

   access_regs_proc : process (CLK_12, RST_N)
   begin
      if (RST_N='0') then
         i_registers <= C_REG_DEFAULT;
      elsif (rising_edge(CLK_12)) then
         
         -- default outputs
         REG_DAT_OUT <= (others => '0');
         REG_RD_VLD  <= '0';
         
         -- If no write is in progress, then a read is valid.
         if (REG_WR_ENB='0') then
            REG_RD_VLD  <= '1';
         end if;
         
         -- ADDR 1 (LOOPBACK)
         if (i_reg_addr=C_LOOPBACK_REG.addr) then
            if (REG_WR_ENB='1') then
               i_registers.loopback_reg <= REG_DAT_IN((C_LOOPBACK_REG.size-1) downto 0);
            else
               REG_DAT_OUT((C_LOOPBACK_REG.size-1) downto 0) <= i_registers.loopback_reg;
            end if;
         end if;
         
         -- ADDR 2 (Accelerometer X Data)
         i_registers.acc_x_data_reg(ACC_X_DATA'range)   <= ACC_X_DATA;
         if (i_reg_addr=C_ACC_X_DATA_REG.addr) then
               REG_DAT_OUT((C_ACC_X_DATA_REG.size-1) downto 0) <= i_registers.acc_x_data_reg;
         end if;
         
         -- ADDR 3 (Accelerometer Y Data)
         i_registers.acc_y_data_reg(ACC_Y_DATA'range)   <= ACC_Y_DATA;
         if (i_reg_addr=C_ACC_Y_DATA_REG.addr) then
               REG_DAT_OUT((C_ACC_Y_DATA_REG.size-1) downto 0) <= i_registers.acc_y_data_reg;
         end if;
         
         -- ADDR 4 (Accelerometer Z Data)
         i_registers.acc_z_data_reg(ACC_Z_DATA'range)   <= ACC_Z_DATA;
         if (i_reg_addr=C_ACC_Z_DATA_REG.addr) then
               REG_DAT_OUT((C_ACC_Z_DATA_REG.size-1) downto 0) <= i_registers.acc_z_data_reg;
         end if;
         
      end if;
   end process access_regs_proc;
end rtl;