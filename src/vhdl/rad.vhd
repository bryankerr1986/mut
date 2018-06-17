--------------------------------------------------------------------------------
--  TITLE: Receive Accelerometer Data (RAD)
--
--  FILENAME: rad.vhd
--
--  AUTHOR: Bryan Kerr
--
--  REVISION: 1.1
--  DATE: 06/01/2018
--
--  DESCRIPTION:
--  
--  Receive data from the on-board accelerometer and place into MUTs internal
--  register space.
--  
--  Set CTRL_REG1 (x"20") to "10011111"
--  This enables 5.376 KHz data rate/ Low-power 8-bit mode/ Enable all axis
--  Wait 1ms for this mode to turn on.
--  
--  Read X-axis data from OUT_X_L (x"28"). Don't need OUT_X_H (x"29").
--  Read Y-axis data from OUT_Y_L (x"2A"). Don't need OUT_Y_H (x"2B").
--  Read Z-axis data from OUT_Z_L (x"2C"). Don't need OUT_Z_H (x"2D").
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
entity rad is
   port
   (
   -- Clocks and Resets -- 
   CLK_12        : in  std_logic; -- 12 MHz clock
   RST_N         : in  std_logic; -- Active low asynchronous reset
   -- SPI RAD ports --
   CLK_SPI       : out std_logic; -- 1 MHz clock
   SPI_CS_N      : out std_logic_vector(0 downto 0); -- Slave (Accelerometer)  Chip Select
   SPI_MOSI      : out std_logic; -- Master (MUT) Out, Slave (Accelerometer) In
   SPI_MISO      : in  std_logic; -- Master (MUT) In,  Slave (Accelerometer) Out
   -- Accelerometer Data --
   ACC_X_DATA    : out std_logic_Vector(7 downto 0); -- Accelerometer X DATA
   ACC_Y_DATA    : out std_logic_Vector(7 downto 0); -- Accelerometer Y DATA
   ACC_Z_DATA    : out std_logic_Vector(7 downto 0)  -- Accelerometer Z DATA
   );
end rad;

architecture rtl of rad is
--------------------------------------------------------------------------------
-- Type declarations
--------------------------------------------------------------------------------
type spi_sm_type is (idle, set_8_bit_mode, wait_between_reads, send_x_reg_req, read_x_reg,
                     send_y_reg_req, read_y_reg, send_z_reg_req, read_z_reg,
                     latch_x_reg, latch_y_reg, latch_z_reg);
--------------------------------------------------------------------------------
-- Constant declarations
--------------------------------------------------------------------------------
constant C_SPI_CLK_DIV  : integer := 6; -- Create 1MHz SPI CLOCK
constant C_WAIT_TO_SEND : integer := 1200;
--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
signal spi_cs  : spi_sm_type; -- SM current state
signal spi_ns  : spi_sm_type; -- SM next state
signal spi_addr     : integer; -- CS address (always '0' since only one slave)
signal spi_en       : std_logic; -- Enables SPI bus
signal spi_data_out : std_logic_vector(7 downto 0); -- Data output on SPI bus
signal spi_busy     : std_logic; -- spi_master is busy with transaction
signal spi_data_in  : std_logic_vector(7 downto 0); -- Data captured on SPI bus
signal spi_cont     : std_logic; -- continue with the SPI transaction
-- counter signals
signal en_wait_cnt   : std_logic; -- enables wait cntr
signal wait_cnt      : std_logic_vector(23 downto 0); -- wait to send counter
signal term_wait_cnt : std_logic; -- starts SM
-- SM outputs
signal latch_x  : std_logic; -- latches in data from SPI bus
signal latch_y  : std_logic; -- latches in data from SPI bus
signal latch_z  : std_logic; -- latches in data from SPI bus
-- SM inputs
signal spi_busy_reg : std_logic; -- registered version of spi_busy
-- others
signal spi_busy_reg1  : std_logic; -- registered version of spi_busy
signal spi_busy_reg2  : std_logic; -- registered version of spi_busy
signal spi_busy_reg3  : std_logic; -- registered version of spi_busy
signal fall_edge_busy : std_logic; -- delayed falling edge of spi_busy (used in SM)
--------------------------------------------------------------------------------
-- Component declarations
--------------------------------------------------------------------------------
component spi_master
  generic
   (
   SLAVES  : integer := 1;  -- number of spi slaves
   D_WIDTH : integer := 1   -- single bit bus
   ); --data bus width
  port
  (
   CLOCK   : in     std_logic;                            -- sys clock
   RESET_N : in     std_logic;                            -- asynchronous reset
   ENABLE  : in     std_logic;                            -- initiate transaction
   CPOL    : in     std_logic;                            -- spi clock polarity
   CPHA    : in     std_logic;                            -- spi clock phase
   CONT    : in     std_logic;                            -- continuous mode command
   CLK_DIV : in     integer;                              -- sys clock cycles per 1/2 period of sclk
   ADDR    : in     integer;                              -- address of slave
   TX_DATA : in     std_logic_vector(d_width-1 downto 0); -- data to transmit
   MISO    : in     std_logic;                            -- master in, slave out
   SCLK    : buffer std_logic;                            -- spi clock
   SS_N    : buffer std_logic_vector(slaves-1 downto 0);  -- slave select
   MOSI    : out    std_logic;                            -- master out, slave in
   BUSY    : out    std_logic;                            -- busy / data ready signal
   RX_DATA : out    std_logic_vector(d_width-1 downto 0)  -- data received
   );
end component;

begin
   
   -- Need to capture a delayed version of falling edge of spi_busy. This
   -- is needed for state machine timing (used to assert spi_cont).
   fall_edge_busy_proc: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            spi_busy_reg1 <= '0';
            spi_busy_reg2 <= '0';
            spi_busy_reg3 <= '0';
         else
            spi_busy_reg1 <= spi_busy;
            spi_busy_reg2 <= spi_busy_reg1;
            spi_busy_reg3 <= spi_busy_reg2;
         end if;
      end if;
   end process fall_edge_busy_proc;
   
   fall_edge_busy <= '1' when (spi_busy_reg3='1' and spi_busy_reg2='0') else '0';
   
   -- When commanded by SM, latch in the Acceleration data in the X direction.
   latch_x_proc: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            ACC_X_DATA <= (others => '0');
         elsif (latch_x='1') then
            ACC_X_DATA <= spi_data_in;
         end if;
      end if;
   end process latch_x_proc;
   
   -- When commanded by SM, latch in the Acceleration data in the Y direction.
   latch_y_proc: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            ACC_Y_DATA <= (others => '0');
         elsif (latch_y='1') then
            ACC_Y_DATA <= spi_data_in;
         end if;
      end if;
   end process latch_y_proc;
   
   -- When commanded by SM, latch in the Acceleration data in the Z direction.
   latch_z_proc: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            ACC_Z_DATA <= (others => '0');
         elsif (latch_z='1') then
            ACC_Z_DATA <= spi_data_in;
         end if;
      end if;
   end process latch_z_proc;

   -- This counter is used as a delay between Accelerometer register reads of
   -- X,Y,Z. Read every 100us.
   one_us_cntr: process(CLK_12, RST_N)
   begin
      if(rising_edge(CLK_12)) then
         if (RST_N='0') then
            wait_cnt <= std_logic_vector(to_unsigned(C_WAIT_TO_SEND-1,wait_cnt'length));
         elsif (en_wait_cnt='1') then
            wait_cnt <= wait_cnt - 1;
            if wait_cnt=(wait_cnt'range => '0') then
               wait_cnt <= std_logic_vector(to_unsigned(C_WAIT_TO_SEND-1,wait_cnt'length));
            end if;
         end if;
      end if;
   end process one_us_cntr;
   
   term_wait_cnt <= '1' when wait_cnt=(wait_cnt'range => '0') else '0';

   -- synchronous process for the state machine
   sm_sync_proc: process(CLK_12, RST_N)
   begin
      if (RST_N='0') then
         spi_cs   <= idle;
      elsif (rising_edge(CLK_12)) then
         spi_cs   <= spi_ns;
      end if;
   end process sm_sync_proc;
   
   spi_sm: process(spi_cs, term_wait_cnt, spi_busy, fall_edge_busy)
   begin
      spi_en       <= '0';
      spi_data_out <= x"20";
      spi_cont     <= '0';
      en_wait_cnt  <= '0';
      latch_x      <= '0';
      latch_y      <= '0';
      latch_z      <= '0';
      spi_ns       <= idle;
      
      case spi_cs is
         when idle =>  -- Idle State
         en_wait_cnt <= '1'; -- Enables 100us timer
            -- Wait for 100us timer to expire.
            if (term_wait_cnt='1') then
               -- Start next write transaction addressing x"20" (CTRL_REG1)
               spi_en  <= '1';
               spi_data_out <= x"20";
               spi_ns    <= set_8_bit_mode;
            end if;
         
         -- set_8_bit_mode puts Accelerometer in low-power mode by writing x"9F"
         -- to register x"20" (CTRL_REG1)
         when set_8_bit_mode =>
            spi_cont <= '1'; -- Continue to write data on SPI bus.
            spi_data_out <= x"9F"; -- Puts Accelerometer in low-power 8-bit mode
            if (spi_busy='0') then
               spi_ns    <= wait_between_reads;
            else
               spi_ns    <= set_8_bit_mode;
            end if;
         
         -- wait_between_reads puts a 100us delay between reads of the X,Y,Z
         -- registers.
         when wait_between_reads =>  -- Idle State
            en_wait_cnt <= '1'; -- Enables 100us timer
            -- Wait for 100us to expire
            if (term_wait_cnt='1') then
            -- Start next read by addressing the X-axis accelerometer register
               spi_en  <= '1';
               spi_data_out <= x"A9"; -- Register x"28" (for a read send x"A8")
               spi_ns    <= send_x_reg_req;
            else
               spi_ns    <= wait_between_reads;
            end if;
         
         -- Sends request to read the X-axis Accelerometer data register.
         when send_x_reg_req =>
            spi_cont <= '1'; -- Continue reading register
            spi_data_out <= x"A9"; -- Register x"28" (for a read send x"A8")
            -- Once register x"28" has been addressed, then transition to the
            -- read_x_reg.
            if (spi_busy='0') then
               spi_ns    <= read_x_reg;
            else
               spi_ns    <= send_x_reg_req;
            end if;
         
         -- Read value out of the X-axis Accelerometer data register.
         when read_x_reg =>  -- 
            spi_data_out <= x"A9"; -- Register x"28" (for a read send x"A8")
            -- Once the read is complete transition to the latch_x_reg state.
            if (spi_busy='0') then
               spi_ns   <= latch_x_reg;
            -- Need to send spi_cont to spi_master in order to receive data.
            elsif (fall_edge_busy='1') then
               spi_cont <= '1';
               spi_ns   <= read_x_reg;
            else
               spi_ns   <= read_x_reg;
            end if;
         
         -- Latches X-axis accelerometer data captured over SPI bus.
         when latch_x_reg =>  -- 
            latch_x   <= '1';
            -- Start next read by addressing the Y-axis accelerometer register
            spi_en    <= '1';
            spi_data_out <= x"AB"; -- Register x"2A" (for a read send x"AA")
            spi_ns    <= send_y_reg_req;
         
         -- Sends request to read the Y-axis Accelerometer data register.
         when send_y_reg_req =>  --
            spi_cont <= '1'; -- Continue reading register
            spi_data_out <= x"AB"; -- Register x"2A" (for a read send x"AA")
            if (spi_busy='0') then
               spi_ns    <= read_y_reg;
            else
               spi_ns    <= send_y_reg_req;
            end if;
         
         -- Read value out of the Y-axis Accelerometer data register.
         when read_y_reg =>  --
            spi_data_out <= x"AB";
            -- Once the read is complete transition to the latch_y_reg state.
            if (spi_busy='0') then
               spi_ns   <= latch_y_reg;
            -- Need to send spi_cont to spi_master in order to receive data.
            elsif (fall_edge_busy='1') then
               spi_cont <= '1'; -- Continue reading register
               spi_ns   <= read_y_reg;
            else
               spi_ns   <= read_y_reg;
            end if;
         
         when latch_y_reg =>  --
            latch_y   <= '1';
            -- Start next read by addressing the Z-axis accelerometer register
            spi_en    <= '1';
            spi_data_out <= x"AD"; -- Register x"2D" (for a read send x"AD")
            spi_ns    <= send_z_reg_req;
         
         -- Sends request to read the Z-axis Accelerometer data register.
         when send_z_reg_req =>  -- 
            spi_cont <= '1'; -- Continue reading register
            spi_data_out <= x"AD"; -- Register x"2D" (for a read send x"AD")
            if (spi_busy='0') then
               spi_ns    <= read_z_reg;
            else
               spi_ns    <= send_z_reg_req;
            end if;
         
         -- Read value out of the Z-axis Accelerometer data register.
         when read_z_reg =>  -- 
            spi_data_out <= x"AD"; -- Register x"2D" (for a read send x"AD")
            -- Once the read is complete transition to the latch_z_reg state.
            if (spi_busy='0') then
               spi_ns   <= latch_z_reg;
            -- Need to send spi_cont to spi_master in order to receive data.
            elsif (fall_edge_busy='1') then
               spi_cont <= '1';
               spi_ns   <= read_z_reg;
            else
               spi_ns   <= read_z_reg;
            end if;
         
         when latch_z_reg =>  -- 
            latch_z   <= '1';
            spi_ns    <= wait_between_reads;
         
         when others => null;
      end case;
   end process spi_sm;


   u_spi_master : spi_master
      generic map
      (
      SLAVES  => 1             ,  -- number of spi slaves
      D_WIDTH => 8                -- data bus width
      )
      port map
      (
      CLOCK   => CLK_12        ,
      RESET_N => RST_N         ,
      ENABLE  => spi_en        ,
      CPOL    => '0'           ,
      CPHA    => '0'           ,
      CONT    => spi_cont      ,
      CLK_DIV => C_SPI_CLK_DIV , -- 1MHz CLK_SPI
      ADDR    => 0             , -- Only one slave
      TX_DATA => spi_data_out  ,
      MISO    => SPI_MISO      ,
      SCLK    => CLK_SPI       ,
      SS_N    => SPI_CS_N      ,
      MOSI    => SPI_MOSI      ,
      BUSY    => spi_busy      ,
      RX_DATA => spi_data_in   
      );
   
end rtl;