library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity u_fifo is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        we          : in std_logic; -- push to fifo
        re          : in std_logic; -- pop from fifo
        ASCIItest   : in std_logic; -- test signal based on button
        data_bus    : in std_logic_vector(7 downto 0);
        --addr     : in  std_logic_vector(4 downto 0);
        data_out    : out std_logic_vector(7 downto 0);
        empty       : out std_logic
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
    signal test_ASCII : std_logic_vector(7 downto 0) := "10101001"; --0xA9

begin

    process (clk, rst)
        variable temp_data : std_logic_vector(7 downto 0);

    begin
        if rst = '1' then
            c_update <= '0';
            data_out <= (others => '0');
            --reset things
            for i in registers'range loop
                registers(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            
            -- write enable (push)
            if we = '1' then
                
                -- push new value to stack
                registers(to_integer(p_ptr)) <= data_bus;
                
                -- push ok as thers available registers
                if reg_full = '0' then
                    items <= items + 1;
                    p_ptr <= p_ptr + 1;
                end if;
                
            -- read enable (pop)
            elsif re = '1' then
                
                -- read first pushed register
                if items /= 0 then
                    data_out <= registers(to_integer(c_ptr));
                    c_update <= '1';
                    c_ptr <= c_ptr + 1;
                    items <= items - 1;
                end if;

                -- "pop" byte from register
                registers(to_integer(c_ptr)) <= (others => '0');
            
            -- simple way of using same pipeline for ASCII
            elsif ASCIItest = '1' then
                data_out <= test_ASCII;
            end if;
            
        end if;
    end process;

    reg_full <= '1' when items = 16 else '0'; -- all 16 registers full
    empty <= '1' when items = 0 else '0'; -- all registers empty

end architecture;
