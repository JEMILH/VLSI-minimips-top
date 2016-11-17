-- Fichier     : minimips_fwd.vhd
-- Description : minimips forwarding module
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity minimips_fwd is

  generic (
    ADDR_WIDTH : positive := 5;
    DATA_WIDTH : positive := 32);

  port (
    in_en       : in  std_logic;        -- enable forwarding
    in_addr_def : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);  -- filtered address
    in_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);  -- input address
    in_data_def : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- input default address
    in_data     : in  std_logic_vector;                       -- input data
    out_data    : out std_logic_vector(DATA_WIDTH - 1 downto 0));  -- output data

end entity minimips_fwd;

architecture behavioral of minimips_fwd is

begin  -- architecture behavioral

  process (in_en, in_addr_def, in_addr, in_data_def, in_data) is
  begin  -- process
    if in_en = '1' then
      if in_addr_def = in_addr then
        out_data <= in_data;
      else
        out_data <= in_data_def;
      end if;
    else
      out_data <= in_data_def;
    end if;
  end process;

end architecture behavioral;
