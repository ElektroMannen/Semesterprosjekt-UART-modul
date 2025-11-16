library ieee;
use ieee.std_logic_1164.all;

--describe module here
entity rx_shiftreg is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        shift_en : in std_logic;                    --sample new bit
        rx_bit   : in std_logic;                    --bit to sample
        clear    : in std_logic;                    --clear shift register
        data     : out std_logic_vector(7 downto 0) --data out
    );
end entity;

architecture rtl of rx_shiftreg is
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
begin

    process (clk, rst)
    begin
        if rst = '1' then
            data_reg <= (others => '0');

        elsif rising_edge(clk) then
            --clear register
            if clear = '1' then
                data_reg <= (others => '0');

            elsif shift_en = '1' then
                --shift new data into register
                data_reg <= rx_bit & data_reg(7 downto 1);
            end if;

        end if;
    end process;

    data <= data_reg;

end architecture;
