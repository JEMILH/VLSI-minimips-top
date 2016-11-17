-- Fichier     : minimips_shifter.vhd
-- Description : Shifter générique.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minimips_shifter is
  generic (STAGES : positive := 5);
  port(
    in_shamt : in  std_logic_vector(STAGES-1 downto 0);
    in_data  : in  std_logic_vector((2**STAGES)-1 downto 0);
    out_data : out std_logic_vector((2**STAGES)-1 downto 0));
end minimips_shifter;

architecture behavioral of minimips_shifter is

  component minimips_mux
    generic (
      width : positive);
    port (
      in_a   : in  std_logic_vector(width-1 downto 0);
      in_b   : in  std_logic_vector(width-1 downto 0);
      in_sel : in  std_logic;
      out_z  : out std_logic_vector(width-1 downto 0));
  end component;


  type   carryType is array(0 to (Stages-1)) of std_logic_vector((2**STAGES)-1 downto 0);
  signal carry : carryType;


  type carryShiftType is array(0 to (Stages-1)) of std_logic_vector((2**STAGES)-1 downto 0);
  signal carry_shift : carryShiftType;

begin
  gen_staeq1 : if (STAGES = 1) generate
    carry_shift(0) <= in_data(0) & '0';
    u_mux : minimips_mux generic map (2**STAGES) port map(in_data, carry_shift(0), in_shamt(0), out_data);
  end generate;

  gen_stasup1 : if (STAGES > 1) generate
    gen_mux : for i in 0 to STAGES - 1 generate
      gen_0 : if (i = 0) generate
        carry_shift(0) <= carry(0)((2**STAGES - 2) downto 0) & '0';
        u_mux : minimips_mux generic map (2**STAGES) port map(carry(0), carry_shift(0), in_shamt(0), out_data);
      end generate gen_0;
      gen_i : if (i > 0 and i < STAGES - 1) generate
        carry_shift(i) <= carry(i)(2**STAGES - 1 - 2**i downto 0) & std_logic_vector(to_unsigned(0, 2**i));
        u_mux : minimips_mux generic map (2**STAGES) port map(carry(i), carry_shift(i), in_shamt(i), carry(i-1));
      end generate gen_i;
      gen_STAGES : if (i = STAGES - 1) generate
        carry_shift(STAGES - 1) <= in_data(2**(STAGES-1) - 1 downto 0) & std_logic_vector(to_unsigned(0, 2**(STAGES-1)));
        u_mux : minimips_mux generic map (2**STAGES) port map(in_data, carry_shift(STAGES - 1), in_shamt(STAGES - 1), carry(i-1));
      end generate gen_STAGES;
    end generate gen_mux;
  end generate;

end behavioral;
