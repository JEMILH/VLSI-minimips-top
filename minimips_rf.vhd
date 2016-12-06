library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minimips_rf is

  generic (
    ADDR_WIDTH : positive := 5;
    DATA_WIDTH : positive := 32);

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

end entity minimips_rf;

architecture behavioral of minimips_rf is

  signal in_clk_n : std_logic;
  type   ram_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ram   : ram_type;

  signal in_addr_ra_c, in_addr_rb_c : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  
begin  -- architecture behavioral

  in_clk_n <= not in_clk;

  process (in_clk, in_rst_n) is
  begin  -- process
    
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      ram <= (others => (others => '0'));
    elsif in_clk'event and in_clk = '1' then  -- writing
      if in_we = '1' then
        if(in_addr_w = std_logic_vector(to_unsigned(0,ADDR_WIDTH))) then
          ram(to_integer(unsigned(in_addr_w))) <= (others => '0');
        else
          ram(to_integer(unsigned(in_addr_w))) <= in_data_w;
        end if;
      end if;
    end if;
    
  end process;

  process (in_clk_n, in_rst_n)
  begin  -- process
    
    if in_rst_n = '0' then              -- asynchronous reset (active low)
      in_addr_ra_c <= (others => '0');
      in_addr_rb_c <= (others => '0');
    elsif in_clk_n'event and in_clk_n = '1' then  -- reading
      in_addr_ra_c <= in_addr_ra;
      in_addr_rb_c <= in_addr_rb;
    end if;
    
  end process;

  out_data_ra <= ram(to_integer(unsigned(in_addr_ra_c)));
  out_data_rb <= ram(to_integer(unsigned(in_addr_rb_c)));
  
end architecture behavioral;
