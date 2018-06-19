--------------------------------------------------------------------------------
-- TITLE: FIR lowpass filter (8 taps)
--
-- FILENAME: mut_top.vhd
--
-- AUTHOR: Bryan Kerr
--
-- REVISION: 1.1
-- DATE: 06/18/2018
--
-- DESCRIPTION:
-- 
-- Simple 8 tap moving average filter.
--  
--------------------------------------------------------------------------------
-- REVISION HISTORY (MANUAL):
-- 06/18/2018 BEK - Initial coding
--
--------------------------------------------------------------------------------
-- Library declarations
--------------------------------------------------------------------------------
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------
entity fir_8 is
   port
   (
   -- Clocks and Resets -- 
   CLK_12        : in  std_logic; -- 12 MHz clock
   RST_N         : in  std_logic; -- Active low asynchronous reset
   -- Data Laches --
   LATCH_DATA    : in  std_logic; -- Indicates new data is available
   -- Data  --
   UNFILTERED_DATA : in  std_logic_Vector(7 downto 0); -- Unfiltered Input
   FILTERED_DATA   : out std_logic_Vector(7 downto 0)  -- Filtered Output
   );
end fir_8;

architecture rtl of fir_8 is
--------------------------------------------------------------------------------
-- Type declarations
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Constant declarations
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
signal tap_n           : signed(7 downto 0);
signal tap_n_minus_1   : signed(7 downto 0);
signal tap_n_minus_2   : signed(7 downto 0);
signal tap_n_minus_3   : signed(7 downto 0);
signal tap_n_minus_4   : signed(7 downto 0);
signal tap_n_minus_5   : signed(7 downto 0);
signal tap_n_minus_6   : signed(7 downto 0);
signal tap_n_minus_7   : signed(7 downto 0);
-- Internal output signal
signal filtered_data_i : signed(7 downto 0);

--------------------------------------------------------------------------------
-- Component declarations
--------------------------------------------------------------------------------
begin

   -- Register 8 most recent data samples.
   cap_input_data_proc: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            tap_n         <= (others => '0');
            tap_n_minus_1 <= (others => '0');
            tap_n_minus_2 <= (others => '0');
            tap_n_minus_3 <= (others => '0');
            tap_n_minus_4 <= (others => '0');
            tap_n_minus_5 <= (others => '0');
            tap_n_minus_6 <= (others => '0');
            tap_n_minus_7 <= (others => '0');
         else
            if (LATCH_DATA='1') then
               tap_n         <= signed(UNFILTERED_DATA);
               tap_n_minus_1 <= tap_n;
               tap_n_minus_2 <= tap_n_minus_1;
               tap_n_minus_3 <= tap_n_minus_2;
               tap_n_minus_4 <= tap_n_minus_3;
               tap_n_minus_5 <= tap_n_minus_4;
               tap_n_minus_6 <= tap_n_minus_5;
               tap_n_minus_7 <= tap_n_minus_6;
            end if;
         end if;
      end if;
   end process cap_input_data_proc;
   
   -- Take the average of all 8 samples (divide by 8 and add).
   filtered_data_i <= (shift_right(tap_n,3)) + (shift_right(tap_n_minus_1,3)) +
                      (shift_right(tap_n_minus_2,3)) + (shift_right(tap_n_minus_3,3)) +
                      (shift_right(tap_n_minus_4,3)) + (shift_right(tap_n_minus_5,3)) +
                      (shift_right(tap_n_minus_6,3)) + (shift_right(tap_n_minus_7,3));
   
   FILTERED_DATA   <= std_logic_vector(filtered_data_i);
   
end rtl;
