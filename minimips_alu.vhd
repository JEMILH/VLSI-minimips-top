-- Fichier     : minimips_alu.vhd
-- Description : ALU du minimips
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minimips_alu is

  generic (
    OP_WIDTH   : positive := 6;
    DATA_WIDTH : positive := 32);

  port (
    in_op      : in  std_logic_vector(OP_WIDTH - 1 downto 0);
    in_funct   : in  std_logic_vector(OP_WIDTH - 1 downto 0);
    in_a       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    in_b       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    out_result : out std_logic_vector(DATA_WIDTH - 1 downto 0));

end entity minimips_alu;

architecture behavioral of minimips_alu is

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

begin  -- architecture behavioral
  process (in_op, in_funct, in_a, in_b) is
  begin  -- process
    case in_op(5 downto 0) is
      when rtype_opcode =>
        case in_funct(5 downto 0) is
          when add_funct =>
            out_result <= std_logic_vector(unsigned(in_a) + unsigned(in_b));
          when sub_funct =>
            out_result <= std_logic_vector(unsigned(in_a) - unsigned(in_b));
          when and_funct =>
            out_result <= in_a and in_b;
          when or_funct =>
            out_result <= in_a or in_b;
          when jr_funct =>
            out_result <= in_a;
          when others =>
            out_result <= in_a;
        end case;
      when addi_opcode | lw_opcode | sw_opcode =>
        out_result <= std_logic_vector(unsigned(in_a) + unsigned(in_b));
      when beq_opcode =>
        out_result <= std_logic_vector(unsigned(in_a) - unsigned(in_b));
      when others =>
        out_result <= in_a;
    end case;
  end process;
end architecture behavioral;
