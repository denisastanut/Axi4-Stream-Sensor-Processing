-- Testbench RECEIVER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UART_receiver_tb is
end UART_receiver_tb;


architecture architecture_uart_receiver_tb of UART_receiver_tb is

    component UART_receiver is
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               rx : in STD_LOGIC;
               data_out : out STD_LOGIC_VECTOR(7 downto 0);
               data_valid : out STD_LOGIC
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal resetn : STD_LOGIC := '0';
    signal rx : STD_LOGIC := '1';
    signal data_out : STD_LOGIC_VECTOR(7 downto 0);
    signal data_valid : STD_LOGIC;

    constant clk_period : time := 10 ns;
    constant baud_period : time := 104.166 us;

begin

    REC: UART_receiver port map(
        clk => clk,
        resetn => resetn,
        rx => rx,
        data_out => data_out,
        data_valid => data_valid
    );

    clk <= not clk after clk_period/2;

    process
    begin
        resetn <= '0';
        wait for 200 ns;
        resetn <= '1';
        wait for 200 ns;

        rx <= '0';
        wait for baud_period;

        rx <= '0'; 
        wait for baud_period; --b0
        rx <= '1'; 
        wait for baud_period; --b1
        rx <= '0'; 
        wait for baud_period; --b2
        rx <= '1'; 
        wait for baud_period; --b3
        rx <= '0'; 
        wait for baud_period; --b4
        rx <= '0'; 
        wait for baud_period; --b5
        rx <= '1'; 
        wait for baud_period; --b6
        rx <= '0'; 
        wait for baud_period; --b7

        rx <= '1';
        wait for baud_period;

        wait;
    end process;

end architecture_uart_receiver_tb;
