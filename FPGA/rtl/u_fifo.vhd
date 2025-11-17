library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_fifo is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        --addr     : in  std_logic_vector(4 downto 0);
        data_in  : in  std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        we       : in  std_logic; --write enable
        re      :  in std_logic
    );
end entity;

architecture rtl of u_fifo is
    type fifo_reg_t is array (0 to 31) of std_logic_vector(7 downto 0);
    signal registers : fifo_reg_t;
    signal ptr_i : integer range 0 to 16 := 0;
    signal prt_o : integer range 0 to 16 := 0;
begin

    process(clk)
    begin
        if rst = '1' then
            --reset things
        elsif rising_edge(clk) then
            if we = '1' then
                registers(ptr_i) <= data_in;
            end if;
        end if;
    end process;


end architecture;
