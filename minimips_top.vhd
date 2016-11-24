-------------------------------------------------------------------------------
-- Project    : ELE8304 : Circuits intégrés à très grande échelle 
-- Description: Conception d'un microprocesseur mini-mips
-------------------------------------------------------------------------------
-- File       : minimips_imem.vhd
-- Author     : Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
-- Lab        : grm@polymtl
-- Created    : 2016-09-23
-- Last update: 2016-11-24
-------------------------------------------------------------------------------
-- Description: Instruction memory 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity minimips_top is
  generic (
    ADDR_WIDTH_MEM : positive := 32);
  port(
    in_rst_n       : in  std_logic;
    in_clk         : in  std_logic;
    in_imem_read   : in  std_logic_vector(31 downto 0);
    in_dmem_read   : in  std_logic_vector(31 downto 0);
    out_dmem_write : out std_logic_vector(31 downto 0);
    out_dmem_we    : out std_logic;
    out_dmem_addr  : out std_logic_vector(ADDR_WIDTH_MEM - 1 downto 0);
    out_imem_addr  : out std_logic_vector(ADDR_WIDTH_MEM - 1 downto 0));
end entity minimips_top;

architecture beh of minimips_top is
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<FETCH>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  constant ADDR_WIDTH_RF : positive := 5;   -- register file addr width
  constant ADDR_WIDTH    : positive := 32;  -- general addr width
  constant DATA_WIDTH    : positive := 32;
  constant BTA_WIDTH     : positive := 16;  -- branch target address width
  constant JTA_WIDTH     : positive := 26;  -- jump target address width


  signal IF_PC   : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal IF_imem : std_logic_vector(ADDR_WIDTH - 1 downto 0);

  component minimips_pc is
    generic (
      ADDR_WIDTH : positive;
      BTA_WIDTH  : positive;
      JTA_WIDTH  : positive);
    port (
      in_clk      : in  std_logic;
      in_rst_n    : in  std_logic;
      in_f_stall  : in  std_logic;
      in_f_jump   : in  std_logic;
      in_f_jumpr  : in  std_logic;
      in_f_branch : in  std_logic;
      in_s_ta     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      out_pc      : out std_logic_vector(ADDR_WIDTH - 1 downto 0));
  end component minimips_pc;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IFID>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  signal IFID_imem : std_logic_vector(ADDR_WIDTH - 1 downto 0);

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<DECODE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  constant rtype_opcode : std_logic_vector(5 downto 0) := "000000";
  constant addi_opcode  : std_logic_vector(5 downto 0) := "001000";
  constant lw_opcode    : std_logic_vector(5 downto 0) := "100011";
  constant sw_opcode    : std_logic_vector(5 downto 0) := "101011";
  constant beq_opcode   : std_logic_vector(5 downto 0) := "000100";
  constant jump_opcode  : std_logic_vector(5 downto 0) := "000010";

  constant add_funct : std_logic_vector(5 downto 0) := "100000";
  constant sub_funct : std_logic_vector(5 downto 0) := "100010";
  constant and_funct : std_logic_vector(5 downto 0) := "100100";
  constant or_funct  : std_logic_vector(5 downto 0) := "100101";
  constant jr_funct  : std_logic_vector(5 downto 0) := "001000";

  component minimips_rf is
    generic (
      ADDR_WIDTH : positive;
      DATA_WIDTH : positive);
    port (
      in_clk      : in  std_logic;
      in_rst_n    : in  std_logic;
      in_we       : in  std_logic;
      in_addr_ra  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      in_addr_rb  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      in_addr_w   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      in_data_w   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      out_data_ra : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      out_data_rb : out std_logic_vector(DATA_WIDTH - 1 downto 0));
  end component minimips_rf;

  signal ID_addr_rs : std_logic_vector(ADDR_WIDTH_MEM - 1 downto 0);
  signal ID_addr_rt : std_logic_vector(ADDR_WIDTH_MEM - 1 downto 0);
  signal ID_addr_rd : std_logic_vector(ADDR_WIDTH_MEM - 1 downto 0);
  signal ID_data_rs : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ID_data_rt : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ID_opcode  : std_logic_vector(5 downto 0);
  signal ID_funct   : std_logic_vector(5 downto 0);
  signal ID_imm     : std_logic_vector(15 downto 0);
  signal ID_target  : std_logic_vector(JTA_WIDTH - 1 downto 0);
  signal ID_wb_addr : std_logic_vector(ADDR_WIDTH_RF - 1 downto 0);
--    signal ID_control
  signal ID_Simm    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ID_ta      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal ID_lw      : std_logic;
  signal ID_ta_sel  : std_logic;
  signal ID_lw      : std_logic;
  signal ID_sw      : std_logic;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IDEX>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  signal IDEX_data_rs : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal IDEX_data_rt : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal IDEX_wb_addr : std_logic_vector(ADDR_WIDTH_RF - 1 downto 0);
--    signal IDEX_control
  signal IDEX_Simm    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal IDEX_ta      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal IDEX_ta_sel  : std_logic;
  signal IDEX_lw      : std_logic;
  signal IDEX_r_type  : std_logic;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXECUTE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  signal EX_branch : std_logic := '0';
  signal EX_jump   : std_logic := '0';
  signal EX_jumpr  : std_logic := '0';
  signal EX_stall  : std_logic := '0';

  signal EX_ta         : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal EX_alu        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal EX_alu_b      : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal EX_dmem_addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal EX_dmem_write : std_logic_vector(DATA_WIDTH - 1 downto 0);

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXME>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  signal EXME_alu        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal EXME_dmem_addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal EXME_dmem_write : std_logic;
  signal EXME_wb_addr    : std_logic_vector(ADDR_WIDTH_RF - 1 downto 0);
  signal EXME_lw         : std_logic;
  signal EXME_sw         : std_logic;
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEMORY>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEWB>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  signal MEWB_alu     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal MEWB_dmem    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal MEWB_wb_addr : std_logic_vector(ADDR_WIDTH_RF - 1 downto 0);
  signal MEWB_lw      : std_logic;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<WRITEBACK>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  signal WB_data : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<FETCH>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  minimips_pc_1 : minimips_pc
    generic map (
      ADDR_WIDTH => ADDR_WIDTH,
      BTA_WIDTH  => BTA_WIDTH,
      JTA_WIDTH  => JTA_WIDTH)
    port map (
      in_clk      => in_clk,
      in_rst_n    => in_rst_n,
      in_f_stall  => EX_stall,
      in_f_jump   => EX_jump,
      in_f_jumpr  => EX_jumpr,
      in_f_branch => EX_branch,
      in_s_ta     => EX_ta,
      out_pc      => IF_PC);

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IFID>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  IDEX : process (in_clk, in_rst_n) is
  begin  -- process MEWB
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      IFID_imem <= (others => '0');
    elsif in_clk'event and in_clk = '1' then  -- rising clock edge
      IFID_imem <= IF_imem;
    end if;
  end process IDEX;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<DECODE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  minimips_rf_1 : minimips_rf
    generic map (
      ADDR_WIDTH => ADDR_WIDTH_RF,
      DATA_WIDTH => DATA_WIDTH)
    port map (
      in_clk      => in_clk,
      in_rst_n    => in_rst_n,
      in_we       => '1',
      in_addr_ra  => ID_addr_rs,
      in_addr_rb  => ID_addr_rt,
      in_addr_w   => MEWB_wb_addr,
      in_data_w   => WB_data,
      out_data_ra => ID_data_ra,
      out_data_rb => ID_data_rb);

  --EXT
  ID_ta(JTA_WIDTH - 1 downto 0)                       <= ID_target;
  ID_ta(ADDR_WIDTH - 1 downto ADDR_WIDTH - JTA_WIDTH) <= (others => '0');

  -- SIGNED-EXT
  ID_Simm(15 downto 0) <= ID_imm;

  ID_Simm(ADDR_WIDTH - 1 downto 16) <= (others => '0') when ID_imm(15) = '0'
                                       else (others => '1');

  --DECODE
  DECODE : process(ID_funct, ID_opcode)
  begin
    case ID_opcode is
      when rtype_opcode =>
        case ID_funct is
          when add_funct | sub_funct | and_funct | or_funct =>
            ID_ta_sel  <= "00";
            ID_lw      <= '0';
            ID_sw      <= '0';
            ID_wb_addr <= ID_addr_rd;
          when jr_funct =>
            ID_ta_sel  <= "10";
            ID_lw      <= '0';
            ID_sw      <= '0';
            ID_wb_addr <= (others => '0');
          when others =>
            ID_ta_sel  <= "00";
            ID_lw      <= '0';
            ID_sw      <= '0';
            ID_wb_addr <= (others => '0');
        end case;
      when addi_opcode =>
        ID_ta_sel  <= "00";
        ID_lw      <= '0';
        ID_sw      <= '0';
        ID_wb_addr <= ID_addr_rt;
      when lw_opcode =>
        ID_ta_sel  <= "00";
        ID_lw      <= '1';
        ID_sw      <= '0';
        ID_wb_addr <= ID_addr_rt;
      when sw_opcode =>
        ID_ta_sel  <= "00";
        ID_lw      <= '0';
        ID_sw      <= '1';
        ID_wb_addr <= (others => '0');
      when beq_opcode =>
        ID_ta_sel  <= "11";
        ID_lw      <= '0';
        ID_sw      <= '0';
        ID_wb_addr <= (others => '0');
      when jump_opcode =>
        ID_ta_sel  <= "01";
        ID_lw      <= '0';
        ID_sw      <= '0';
        ID_wb_addr <= (others => '0');
      when others =>
        ID_ta_sel  <= "00";
        ID_lw      <= '0';
        ID_sw      <= '0';
        ID_wb_addr <= (others => '0');
    end case;
  end process;


--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<IDEX>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  IDEX : process (in_clk, in_rst_n) is
  begin  -- process MEWB
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      IDEX_data_rt <= (others => '0');
      IDEX_data_rs <= (others => '0');
      IDEX_ta_sel  <= '0';
      IDEX_wb_addr <= (others => '0');
      IDEX_lw      <= '0';
      IDEX_sw      <= '0';
      IDEX_Simm    <= (others => '0');
      IDEX_ta      <= (others => '0');
    elsif in_clk'event and in_clk = '1' then  -- rising clock edge
      IDEX_data_rt <= ID_data_rt;
      IDEX_data_rs <= ID_data_rs;
      IDEX_ta_sel  <= ID_ta_sel;
      IDEX_wb_addr <= ID_wb_addr;
      IDEX_lw      <= ID_lw;
      IDEX_sw      <= ID_sw;
      IDEX_Simm    <= ID_Simm;
      IDEX_ta      <= ID_ta
    end if;
  end process IDEX;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXECUTE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--

  minimips_alu_1 : minimips_alu
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      in_op      => IDEX_op,
      in_funct   => IDEX_funct,
      in_a       => IDEX_data_rs,
      in_b       => EX_alu_b,
      out_result => out_result);

  EX_branch <= '1' when EX_alu = std_logic_vector(to_unsigned(0, DATA_WIDTH)) else '0';

  EX_ta <= EX_alu when IDEX_ta_sel = '1' else IDEX_ta;
  process(EX_alu, IDEX_ta, IDEX_Simm, IDEX_ta_sel)
  begin
    case IDEX_ta_sel is
      when "00" =>
        EX_ta <= (others => '0');
      when "01" =>
        EX_ta <= IDEX_ta;
      when "10" =>
        EX_ta <= EX_alu;
      when "11" =>
        EX_ta <= IDEX_Simm;
    end case;
  end process;


  EX_alu_b <= IDEX_data_rt when IDEX_r_type = '1' else IDEX_Simm;

  EX_dmem_addr  <= EX_alu;
  EX_dmem_write <= IDEX_data_rt;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<EXME>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  MEWB : process (in_clk, in_rst_n) is
  begin  -- process MEWB
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      EXME_sw         <= '0';
      EXME_lw         <= '0';
      EXME_wb_addr    <= (others => '0');
      EXME_dmem_write <= (others => '0');
      EXME_dmem_addr  <= (others => '0');
      EXME_alu        <= (others => '0');

    elsif in_clk'event and in_clk = '1' then  -- rising clock edge
      EXME_sw         <= IDEX_sw;
      EXME_lw         <= IDEX_lw;
      EXME_wb_addr    <= IDEX_wb_addr;
      EXME_dmem_write <= EX_dmem_write;
      EXME_dmem_addr  <= EX_dmem_addr;
      EXME_alu        <= EX_alu;
    end if;
  end process MEWB;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<MEMORY>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
  out_dmem_addr  <= EXME_dmem_addr(ADDR_WIDTH_MEM + 1 downto 2);
  out_dmem_we    <= EXME_sw;
  out_dmem_write <= EXME_dmem_write;
  MEWB_dmem      <= in_dmem_read;



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
