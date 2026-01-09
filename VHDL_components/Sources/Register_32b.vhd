-- REGISTER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Register_32b is
    Port ( clk : in  STD_LOGIC;
           aresetn : in  STD_LOGIC;
           en : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (31 downto 0);
           Q : out STD_LOGIC_VECTOR (31 downto 0));
end Register_32b;


architecture architecture_reg of Register_32b is

    signal q_int : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
begin

    process(clk, aresetn)
    begin
        if aresetn = '0' then
            q_int <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                q_int <= D;
            end if;
        end if;
    end process;

    Q <= q_int;
    
end architecture_reg;
