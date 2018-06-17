--------------------------------------------------------------------------------
--  TITLE: LED Blink
--
--  FILENAME: led_blink.vhd
--
--  AUTHOR: Bryan Kerr
--
--  REVISION: 1.1
--  DATE: 06/01/2018
--
--  DESCRIPTION:
--  
--  Blinks the 8 LEDS
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

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------
entity led_blink is
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
end led_blink;

architecture rtl of led_blink is
--------------------------------------------------------------------------------
-- Constant declarations
--------------------------------------------------------------------------------
constant C_LED_CNT  : integer := 3000000;

--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
-- LED signals
signal i_led      : std_logic;                     -- internal LED signal
signal led_cnt    : std_logic_vector(23 downto 0); -- LED counter

begin

   -- This process is used to blink the 8 LEDs on board.
   -- The LEDs are blinked at a rate of (C_LED_CNT/12000000)
   flash_led_proc: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            led_cnt <= std_logic_vector(to_unsigned(C_LED_CNT-1,led_cnt'length));
            i_led  <= '0';
         else
            led_cnt <= led_cnt - 1;
            if led_cnt=(led_cnt'range => '0') then
               led_cnt <= std_logic_vector(to_unsigned(C_LED_CNT-1,led_cnt'length));
               i_led  <= not(i_led);
            end if;
         end if;
      end if;
   end process flash_led_proc;
   
   LED1 <= i_led;
   LED2 <= i_led;
   LED3 <= i_led;
   LED4 <= i_led;
   LED5 <= not(i_led);
   LED6 <= not(i_led);
   LED7 <= not(i_led);
   LED8 <= not(i_led);

end rtl;