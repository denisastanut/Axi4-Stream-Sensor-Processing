-- SUBTRACTOR

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Subtractor_32b is
    Port ( a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           d : out STD_LOGIC_VECTOR (31 downto 0);
           cout : out STD_LOGIC);
end Subtractor_32b;


architecture architecture_sub of Subtractor_32b is

    signal b_inv : STD_LOGIC_VECTOR(31 downto 0);
    signal aux : STD_LOGIC_VECTOR(32 downto 0);
    
    component Adder_32b is
        Port (a : in  STD_LOGIC_VECTOR (31 downto 0);
              b : in  STD_LOGIC_VECTOR (31 downto 0);
              cin : in  STD_LOGIC;
              s : out STD_LOGIC_VECTOR (31 downto 0);
              cout : out STD_LOGIC);
    end component;
    
begin

    b_inv <= not b;
    
    ADDER: Adder_32b port map(
        a => a,
        b => b_inv,
        cin => '1',
        s => d,
        cout => cout);
        
end architecture_sub;
