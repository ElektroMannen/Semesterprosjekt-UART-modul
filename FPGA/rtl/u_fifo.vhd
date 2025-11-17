library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_fifo is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        addr     : in  std_logic_vector(4 downto 0);
        data_in  : in  std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        we       : in  std_logic --write enable
    );
end entity;

architecture rtl of u_fifo is
    type fifo_reg_t is array (0 to 31) of std_logic_vector(7 downto 0);
    signal registers : fifo_reg_t;
begin

    process(clk)
    begin
        if rst = '1' then
            --reset things
        elsif rising_edge(clk) then
            --do things
        end if;
    end process;
end architecture;
