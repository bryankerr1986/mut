--------------------------------------------------------------------------------
--  TITLE: Register Map Package
--
--  FILENAME: reg_map.vhd
--
--  AUTHOR: Bryan Kerr
--
--  REVISION: 1.1
--  DATE: 06/01/2018
--
--  DESCRIPTION:
--  
--  Defines the registers contained within the MUT.
--  
--  
--  
--------------------------------------------------------------------------------
--  REVISION HISTORY (MANUAL):
--  04/14/2018 BEK - Initial coding
--
--------------------------------------------------------------------------------
-- Library declarations
--------------------------------------------------------------------------------
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package reg_map_pkg is
   
   type reg_map_record is record
      addr : natural;
      size : natural;
   end record;
   
      -- read/write
   constant C_LOOPBACK_REG      : reg_map_record := (1, 8); -- Loopback
      -- read only              
   constant C_ACC_X_DATA_REG    : reg_map_record := (2, 8); -- Accelerometer X Data
      -- read only              
   constant C_ACC_Y_DATA_REG    : reg_map_record := (3, 8); -- Accelerometer Y Data
      -- read only              
   constant C_ACC_Z_DATA_REG    : reg_map_record := (4, 8); -- Accelerometer Z Data
   
   -- Other Constants
   constant C_MAX_REG_SIZE         : natural := 8;
   constant C_MAX_ADDRESS_SIZE     : natural := 7; -- How many bits needed
                                                   -- to address largest addr
   
   type reg_record is record
      loopback_reg          : std_logic_vector((C_LOOPBACK_REG.size-1) downto 0);
      acc_x_data_reg        : std_logic_vector((C_ACC_X_DATA_REG.size-1) downto 0);
      acc_y_data_reg        : std_logic_vector((C_ACC_Y_DATA_REG.size-1) downto 0);
      acc_z_data_reg        : std_logic_vector((C_ACC_Z_DATA_REG.size-1) downto 0);
   end record;
   
   constant C_REG_DEFAULT : reg_record :=
      (
      loopback_reg      => (others => '0'),
      acc_x_data_reg    => (others => '0'),
      acc_y_data_reg    => (others => '0'),
      acc_z_data_reg    => (others => '0')
      );
   
end package reg_map_pkg;

package body reg_map_pkg is
end package body reg_map_pkg;