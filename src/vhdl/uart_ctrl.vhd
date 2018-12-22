--------------------------------------------------------------------------------
--  TITLE: UART controller
--
--  FILENAME: uart_ctrl.vhd
--
--  AUTHOR: Bryan Kerr
--
--  REVISION: 2
--  DATE: 12/21/2018
--
--  DESCRIPTION:
--  
--  Send and Receive data to the register map via UART
--  
--  
--------------------------------------------------------------------------------
--  REVISION HISTORY (MANUAL):
--  05/03/2018 BEK - Initial coding
--  12/21/2018 BEK - Changed UART baud rate from 115200 to 9600 because 115200
--                   was giving errors at the receiver.
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

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------
entity uart_ctrl is
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
   REG_DAT_IN        : out std_logic_vector(C_MAX_REG_SIZE-1 downto 0);
   REG_DAT_OUT       : in  std_logic_vector(C_MAX_REG_SIZE-1 downto 0);
   REG_RD_VLD        : in  std_logic;
   UART_FIFO_DATA    : out std_logic_Vector(7 downto 0)
   );
end uart_ctrl;

architecture rtl of uart_ctrl is
--------------------------------------------------------------------------------
-- Component declarations
--------------------------------------------------------------------------------

component uart_fifo
   port
   (
   CLOCK    : in  std_logic;
   DATA     : in  std_logic_vector (7 downto 0);
   RDREQ    : in  std_logic;
   SCLR     : in  std_logic;
   WRREQ    : in  std_logic;
   FULL     : out std_logic;
   Q        : out std_logic_vector (7 downto 0);
   USEDW    : out std_logic_vector (10 downto 0)
   );
end component;

component uart_rx
   generic
   (
   G_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
   );
   port
   (
   I_CLK       : in  std_logic;
   I_RX_SERIAL : in  std_logic;
   O_RX_DV     : out std_logic;
   O_RX_BYTE   : out std_logic_vector(7 downto 0)
   );
end component;

component uart_tx
   generic
   (
   G_CLKS_PER_BIT : integer := 115     -- (12000000)/(9600) = 1250
   );
   port
   (
   I_CLK       : in  std_logic;
   I_TX_DV     : in  std_logic;
   I_TX_BYTE   : in  std_logic_vector(7 downto 0);
   O_TX_ACTIVE : out std_logic;
   O_TX_SERIAL : out std_logic;
   O_TX_DONE   : out std_logic
   );
end component;
--------------------------------------------------------------------------------
-- Type declarations
--------------------------------------------------------------------------------
type uart_sm_type is (idle, reg_access, write_fifo, read_fifo, wait_state);
--------------------------------------------------------------------------------
-- Constant declarations
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
signal uart_cs  : uart_sm_type; -- SM current state
signal uart_ns  : uart_sm_type; -- SM next state
-- UART signals
signal i_tx_dv           : std_logic; -- Tells uart_tx to send data
signal o_tx_active       : std_logic; -- uart_tx is transmitting
signal rx_byte           : std_logic_vector(7 downto 0); -- Received byte
signal rx_done           : std_logic; -- received done
-- internal signals
signal rx_cnt            : std_logic; --
--signal i_reg_wr_enb      : std_logic; --
signal zero_fill_dat_in  : std_logic_vector(C_MAX_REG_SIZE-1 downto 8);
signal i_reg_addr        : std_logic_vector(C_MAX_ADDRESS_SIZE-1 downto 0);
signal feature_cnt       : std_logic_vector(7 downto 0); -- How many features left
-- FIFO signals
signal fifo_data_in      : std_logic_vector(7 downto 0);
signal fifo_rd_enb       : std_logic;
signal fifo_wr_enb       : std_logic;
signal fifo_full         : std_logic;
signal fifo_data_out     : std_logic_vector(7 downto 0);
signal fifo_word_cnt     : std_logic_vector(10 downto 0);
signal rst_fifo          : std_logic;

signal access_fifo       : std_logic;
signal wr_rd_n           : std_logic;
signal latch_addr        : std_logic;
signal latch_feat_cnt    : std_logic;
signal subtract_feat_cnt : std_logic;
signal term_cnt          : std_logic;
signal uart_tx_data      : std_logic_vector(7 downto 0);

signal uart_tx_done      : std_logic;
      
begin

   -- Unused
   RXD <= uart_tx_done;
   UART_FIFO_DATA <= fifo_word_cnt(7 downto 0);
   
   zero_fill_dat_in <= (others => '0');
   DSR_N <= '1';
   CTS_N <= not(o_tx_active);

   -- 
   latch_addr_proc: process(CLK_12, RST_N)
   begin
      if (RST_N='0') then
         wr_rd_n    <= '0';
         i_reg_addr <= (others => '0');
      elsif (rising_edge(CLK_12)) then
         if (latch_addr='1') then
            wr_rd_n    <= rx_byte(7);
            i_reg_addr <= rx_byte(6 downto 0);
         end if;
      end if;
   end process latch_addr_proc;
   
   REG_ADDR    <= i_reg_addr;
   access_fifo <= '1' when i_reg_addr="1111111" else '0';

   -- 
   feat_cnt_proc: process(CLK_12, RST_N)
   begin
      if (RST_N='0') then
         feature_cnt   <= (others => '0');
      elsif (rising_edge(CLK_12)) then
         if (latch_feat_cnt='1') then
            feature_cnt  <= rx_byte;
         elsif (subtract_feat_cnt='1') then
            feature_cnt  <= feature_cnt - 1;
         end if;
      end if;
   end process feat_cnt_proc;
   
   term_cnt <= '1' when feature_cnt=x"00" else '0';
   
   uart_tx_data <= fifo_data_out when uart_cs=read_fifo else REG_DAT_OUT(7 downto 0);

   -- synchronous process for the state machine
   sm_sync_proc: process(CLK_12, RST_N)
   begin
      if (RST_N='0') then
         rst_fifo  <= '1';
         uart_cs   <= idle;
      elsif (rising_edge(CLK_12)) then
         rst_fifo  <= '0';
         uart_cs   <= uart_ns;
      end if;
   end process sm_sync_proc;
   
   -- UART controller State Machine
   uart_sm: process(uart_cs, rx_done, access_fifo, wr_rd_n, zero_fill_dat_in,
                    rx_byte, REG_RD_VLD, term_cnt, fifo_full, o_tx_active,
                    uart_tx_done)
   begin
      latch_addr        <= '0';
      latch_feat_cnt    <= '0';
      REG_DAT_IN        <= (others => '0');
      REG_WR_ENB        <= '0';
      i_tx_dv           <= '0';
      fifo_wr_enb       <= '0';
      fifo_data_in      <= (others => '0');
      subtract_feat_cnt <= '0';
      fifo_rd_enb       <= '0';
      uart_ns           <= idle;
      
      case uart_cs is
         when idle =>  -- Idle State
            -- If data has been sent to the UART receiver, then transition to
            -- the reg_access state.
            latch_addr <= '1';
            if (rx_done='1') then
               latch_addr <= '1';
               uart_ns    <= reg_access;
            end if;
            
         when reg_access =>
            if (rx_done='1' and access_fifo='1' and wr_rd_n='1') then
               latch_feat_cnt <= '1';
               uart_ns  <= write_fifo;
            elsif (rx_done='1' and access_fifo='1' and wr_rd_n='0') then
               latch_feat_cnt <= '1';
               fifo_rd_enb    <= '1';
               uart_ns <= read_fifo;
            elsif (rx_done='1' and access_fifo='0' and wr_rd_n='1') then
               REG_DAT_IN <= zero_fill_dat_in & rx_byte(7 downto 0);
               REG_WR_ENB <= '1';
               uart_ns    <= idle;
            elsif (access_fifo='0' and wr_rd_n='0' and REG_RD_VLD='1') then
               i_tx_dv    <= '1';
               uart_ns    <= idle;
            else
               uart_ns    <= reg_access;
            end if;
            
         when write_fifo =>
            if (term_cnt='1') then
               uart_ns <= idle;
            elsif (rx_done='1' and wr_rd_n='1' and term_cnt='0' and fifo_full='0') then
               subtract_feat_cnt <= '1';
               fifo_wr_enb  <= '1';
               fifo_data_in <= rx_byte;
               uart_ns <= write_fifo;
            else
               uart_ns <= write_fifo;
            end if;
         
         when read_fifo =>
            if (term_cnt='1') then
               uart_ns <= idle;
            elsif (o_tx_active='0' and term_cnt='0') then
               subtract_feat_cnt <= '1';
               i_tx_dv <= '1';
               uart_ns <= wait_state;
            else
               uart_ns <= read_fifo;
            end if;
         
         when wait_state =>
            if (term_cnt='1') then
               uart_ns <= idle;
            elsif (uart_tx_done='1') then
               fifo_rd_enb <= '1';
               uart_ns <= read_fifo;
            else
               uart_ns <= wait_state;
            end if;
               
         
         when others => null;
      end case;
   end process uart_sm;


--------------------------------------------------------------------------------
-- Instantiations
--------------------------------------------------------------------------------
   u_uart_rx : uart_rx
      generic map
      (
      G_CLKS_PER_BIT => 1250     -- (12000000)/(9600) = 1250
      )
      port map
      (
      I_CLK          => CLK_12        ,
      I_RX_SERIAL    => TXD           ,
      O_RX_DV        => rx_done       ,
      O_RX_BYTE      => rx_byte
      );

   u_uart_tx : uart_tx
      generic map
      (
      G_CLKS_PER_BIT => 1250     -- (12000000)/(9600) = 1250
      )
      port map
      (
      I_CLK       => CLK_12                       ,
      I_TX_DV     => i_tx_dv                      ,
      I_TX_BYTE   => uart_tx_data                 ,
      O_TX_ACTIVE => o_tx_active                  ,
      O_TX_SERIAL => uart_tx_done                 ,
      O_TX_DONE   => open        
      );
      
   uart_fifo_inst : uart_fifo
      port map
      (
      CLOCK => CLK_12              ,
      DATA  => fifo_data_in        ,
      SCLR  => rst_fifo            ,
      RDREQ => fifo_rd_enb         ,
      WRREQ => fifo_wr_enb         ,
      FULL  => fifo_full           ,
      Q     => fifo_data_out       ,
      USEDW => fifo_word_cnt
      );
   
end rtl;