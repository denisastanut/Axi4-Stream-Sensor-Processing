-- SSD

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity display_7seg is
    Port ( digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           clk : in STD_LOGIC;
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC
    );
end display_7seg;


architecture ssd_architecture of display_7seg is

    signal cnt : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal digit_to_display : STD_LOGIC_VECTOR (3 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then 
            cnt <= cnt + 1; 
        end if;
    end process;

    
    digit_to_display <= digit0 when cnt(15 downto 14) = "00" else
                        digit1 when cnt(15 downto 14) = "01" else
                        digit2 when cnt(15 downto 14) = "10" else
                        digit3;

    an <= "1110" when cnt(15 downto 14) = "00" else
          "1101" when cnt(15 downto 14) = "01" else
          "1011" when cnt(15 downto 14) = "10" else
          "0111";

    dp <= '0' when cnt(15 downto 14) = "10" else '1';

    with digit_to_display select
    cat <= "1111001" when "0001", -- 1
           "0100100" when "0010", -- 2
           "0110000" when "0011", -- 3
           "0011001" when "0100", -- 4
           "0010010" when "0101", -- 5
           "0000010" when "0110", -- 6
           "1111000" when "0111", -- 7
           "0000000" when "1000", -- 8
           "0010000" when "1001", -- 9
           "0101111" when "1010", -- r 
           "1111111" when "1011", -- blank
           "1000111" when "1100", -- L
           "1000001" when "1101", -- U
           "0000110" when "1110", -- E
           "1111111" when "1111", -- space
           "1000000" when others; -- 0

end ssd_architecture;