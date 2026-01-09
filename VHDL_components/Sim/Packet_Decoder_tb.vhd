-- Testbench DECODER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Packet_Decoder_tb is
end Packet_Decoder_tb;


architecture architecture_packet_decoder_tb of Packet_Decoder_tb is

    component Packet_Decoder is
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               data_in : in STD_LOGIC_VECTOR(7 downto 0);
               data_valid : in STD_LOGIC;
               packet_out : out STD_LOGIC_VECTOR(15 downto 0);
               packet_valid : out STD_LOGIC
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal resetn : STD_LOGIC := '0';

    signal data_in : STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
    signal data_valid : STD_LOGIC := '0';

    signal packet_out : STD_LOGIC_VECTOR(15 downto 0);
    signal packet_valid : STD_LOGIC;

    constant clk_period : time := 10 ns;

begin

    DEC: Packet_Decoder port map (
        clk => clk,
        resetn => resetn,
        data_in => data_in,
        data_valid => data_valid,
        packet_out => packet_out,
        packet_valid => packet_valid
    );

    clk <= not clk after clk_period/2;

    proc_reset : process
    begin
        resetn <= '0';
        wait for 40 ns;
        resetn <= '1';
        wait;
    end process;

    proc_sim : process
    begin
        wait until resetn='1';
        wait for 20 ns;

        -- correct package
        data_valid <= '1';
        data_in <= x"AA"; 
        wait for clk_period;
        data_in <= x"12"; 
        wait for clk_period;
        data_in <= x"34"; 
        wait for clk_period;
        data_in <= x"55"; 
        wait for clk_period;
        data_valid <= '0';
        wait for 40 ns;

        -- wrong package
        data_valid <= '1';
        data_in <= x"AA"; 
        wait for clk_period;
        data_in <= x"0A"; 
        wait for clk_period;
        data_in <= x"0B"; 
        wait for clk_period;
        data_in <= x"99"; 
        wait for clk_period;
        data_valid <= '0';
        wait for 40 ns;

        -- another correct one
        data_valid <= '1';
        data_in <= x"AA"; 
        wait for clk_period;
        data_in <= x"AB"; 
        wait for clk_period;
        data_in <= x"CD"; 
        wait for clk_period;
        data_in <= x"55"; 
        wait for clk_period;
        data_valid <= '0';
        wait;

    end process;

end architecture_packet_decoder_tb;
