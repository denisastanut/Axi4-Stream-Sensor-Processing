-- ADDER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Adder_32b is
    Port (a : in  STD_LOGIC_VECTOR (31 downto 0);
          b : in  STD_LOGIC_VECTOR (31 downto 0);
          cin : in  STD_LOGIC;
          s : out STD_LOGIC_VECTOR (31 downto 0);
          cout : out STD_LOGIC);
end Adder_32b;


architecture architecture_add of Adder_32b is

    type carry_a is array (0 to 32) of STD_LOGIC;
    signal carry : carry_a;
    
    signal sum : std_logic_vector(31 downto 0);
    
begin
    carry(0) <= cin;
    
    full_adders: for i in 0 to 31 generate
        sum(i) <= a(i) xor b(i);
        s(i) <= sum(i) xor carry(i);
        carry(i+1) <= (a(i) and b(i)) or (sum(i) and carry(i));
    end generate;
    
    cout <= carry(32);
    
end architecture_add;
