-- Fichier     : minimips_pc.vhd
-- Description : minimips program counter module
-------------------------------------------------------------------------------
library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minimips_pc is

  generic (
    ADDR_WIDTH : positive := 32;
    BTA_WIDTH  : positive := 16;        -- branch target address
    JTA_WIDTH  : positive := 26);       -- jump target address

  port (
    in_clk      : in  std_logic;
    in_rst_n    : in  std_logic;
    in_f_stall  : in  std_logic;
    in_f_jump   : in  std_logic;
    in_f_jumpr  : in  std_logic;
    in_f_branch : in  std_logic;
    in_s_ta     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    out_pc      : out std_logic_vector(ADDR_WIDTH - 1 downto 0));

end entity minimips_pc;

architecture behavioral of minimips_pc is

  component minimips_shifter
    generic (
      STAGES : positive);
    port (
      in_shamt : in  std_logic_vector(STAGES-1 downto 0);
      in_data  : in  std_logic_vector((2**STAGES)-1 downto 0);
      out_data : out std_logic_vector((2**STAGES)-1 downto 0));
  end component;

  constant STAGES : positive := positive(ceil(log2(real(ADDR_WIDTH))));
    
  signal in_shamt : std_logic_vector(STAGES-1 downto 0);
  signal in_data  : std_logic_vector((2**STAGES)-1 downto 0);
  signal out_data : std_logic_vector((2**STAGES)-1 downto 0);
  
  --next and current pc
  signal current_pc, next_pc : unsigned(ADDR_WIDTH - 1 downto 0);

begin  -- architecture behavioral
  in_shamt <= std_logic_vector(to_unsigned(2,STAGES));
  in_data <= std_logic_vector(to_unsigned(0,2**STAGES - BTA_WIDTH)) & in_s_ta(BTA_WIDTH - 1 downto 0);
  out_pc <= std_logic_vector(current_pc);

  pc_register : process (in_clk, in_rst_n) is
  begin  -- process pc_register
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      current_pc <= (others => '0');
    elsif in_clk'event and in_clk = '1' then  -- rising clock edge
      current_pc <= next_pc;
    end if;
  end process pc_register;

  next_pc_logic : process (in_s_ta, in_f_stall, in_f_jump, in_f_jumpr, in_f_branch, current_pc) is

    variable pc_plus_4 : unsigned(ADDR_WIDTH - 1 downto 0);

  begin  -- process next pc logic
    pc_plus_4 := current_pc + to_unsigned(4, ADDR_WIDTH);

    if (in_f_stall = '1') then
      next_pc <= current_pc;
    elsif (in_f_branch = '1') then
      next_pc <= pc_plus_4 + unsigned(out_data);
    elsif (in_f_jumpr = '1') then
      next_pc <= unsigned(in_s_ta);
    elsif (in_f_jump = '1') then
      next_pc <= pc_plus_4(ADDR_WIDTH - 1 downto JTA_WIDTH +2) & unsigned(in_s_ta(JTA_WIDTH - 1 downto 0) & "00");
    else
      next_pc <= pc_plus_4;
    end if;

  end process next_pc_logic;

  minimips_shifter_1: minimips_shifter
    generic map (
      STAGES => STAGES)
    port map (
      in_shamt => in_shamt,
      in_data  => in_data,
      out_data => out_data);
  
end architecture behavioral;
