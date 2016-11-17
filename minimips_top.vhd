-------------------------------------------------------------------------------
-- Project    : ELE8304 : Circuits intégrés à très grande échelle 
-- Description: Conception d'un microprocesseur mini-mips
-------------------------------------------------------------------------------
-- File       : minimips_imem.vhd
-- Author     : Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab        : grm@polymtl
-- Created    : 2016-09-23
-- Last update: 2016-11-17
-------------------------------------------------------------------------------
-- Description: Instruction memory 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity minimips_top is
  port(
    in_rst_n       : in  std_logic;
    in_clk         : in  std_logic;
    in_imem_read   : in  std_logic_vector(31 downto 0);
    in_dmem_read   : in  std_logic_vector(31 downto 0);
    out_dmem_write : out std_logic_vector(31 downto 0);
    out_dmem_we    : out std_logic;
    out_dmem_addr  : out std_logic_vector(9 downto 0);
    out_imem_addr  : out std_logic_vector(9 downto 0));
end entity minimips_top;

architecture beh of minimips_top is
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<FETCH>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal IF_PC : std_logic_vector(31 downto 0);
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IFID>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<DECODE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal ID_rs
    signal ID_rt
    signal ID_opcode
    signal ID_funct
    signal ID_im
    signal ID_target
    signal ID_RS
    signal ID_RT
    signal ID_wb_addr
    signal ID_control
    signal ID_Sim
    signal ID_ta
    signal ID_lw : std_logic;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IDEX>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal IDEX_RS
    signal IDEX_RT
    signal IDEX_wb_addr
    signal IDEX_control
    signal IDEX_Sim
    signal IDEX_ta
    signal IDEX_lw : std_logic;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXECUTE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal EX_branch
    signal EX_ta
    signal EX_alu
    signal EX_dmem_addr
    signal EX_dmem_write

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXME>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
    signal EXME_alu
    signal EXME_dmem_addr
    signal EXME_dmem_write
    signal EXME_wb_addr
    signal EXME_lw : std_logic;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEMORY>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEWB>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal MEWB_alu     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal MEWB_dmem    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal MEWB_wb_addr : std_logic_vector(ADDR_WIDTH_RF - 1 downto 0);
  signal MEWB_lw      : std_logic;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<WRITEBACK>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal WB_data
begin
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<FETCH>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IFID>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<DECODE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--


--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IDEX>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXECUTE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXME>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEMORY>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEWB>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  MEWB : process (in_clk, in_rst_n) is
  begin  -- process MEWB
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      MEWB_alu     <= (others => '0');
      MEWB_wb_addr <= (others => '0');
      MEWB_lw      <= '0';
    elsif in_clk'event and in_clk = '1' then  -- rising clock edge
      MEWB_alu     <= EXME_alu;
      MEWB_wb_addr <= EXME_wb_addr;
      MEWB_lw      <= EXME_lw;
    end if;
  end process MEWB;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<WRITEBACK>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  WB_data <= MEWB_dmem when MEWB_lw = '1' else MEWB_alu;

end architecture beh;
