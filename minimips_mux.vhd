-- Fichier     : minimips_mux.vhd
-- Description : Multiplexeur à deux entrées. Largeur variable selon width.
-------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minimips_mux is 
	generic (width : positive := 32);
	port( 
		in_a   : in std_logic_vector(width-1 downto 0); 
		in_b   : in std_logic_vector(width-1 downto 0); 
		in_sel : in std_logic;
		out_z  : out std_logic_vector(width-1 downto 0));
end minimips_mux;

architecture behavioral of minimips_mux is
   
begin
	do_mux : process (in_sel,in_a,in_b) 
	begin
		if (in_sel = '0') then
			out_z <= in_a;
		else
			out_z <= in_b;
		end if;
	end process do_mux;
end behavioral;
