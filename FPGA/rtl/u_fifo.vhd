library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_fifo is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        --addr     : in  std_logic_vector(4 downto 0);
        data_in  : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        we       : in std_logic; --write enable
        re       : in std_logic
    );
end entity;

architecture rtl of u_fifo is
    type fifo_reg_t is array (0 to 15) of std_logic_vector(7 downto 0);
    signal registers : fifo_reg_t;
    
    --signal p_ptr : integer range 0 to 16 := 0;
    signal p_ptr : unsigned(3 downto 0) := (others => '0'); --producer
    signal c_ptr : unsigned(3 downto 0) := (others => '0'); --consumer
    signal full : std_logic := '0';
    signal c_update : std_logic := '0';
    signal items : integer range 0 to 16 := 0;
    signal reg_full : std_logic;

begin

    process (clk, rst)
        variable temp_data : std_logic_vector(7 downto 0);

    begin
        if rst = '1' then
            c_update <= '0';
            --reset things
            --for i in registers'range loop
            --    registers(i) <= (others => '0');
            --end loop;
        elsif rising_edge(clk) then
            
            if we = '1' then
                
                registers(to_integer(p_ptr)) <= data_in;
                
                if reg_full = '0' then
                    items <= items + 1;
                    p_ptr <= p_ptr + 1;
                end if;
                
            elsif re = '1' then
                
                if items /= 0 then
                    data_out <= registers(to_integer(c_ptr));
                    c_update <= '1';
                    c_ptr <= c_ptr + 1;
                    items <= items - 1;
                end if;

                registers(to_integer(c_ptr)) <= (others => '0');
                
            end if;
            
        end if;
    end process;

    reg_full <= '1' when items = 16 else '0';


end architecture;
