-- PACKET DECODER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Packet_Decoder is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR(7 downto 0);
           data_valid : in STD_LOGIC;
           packet_out : out STD_LOGIC_VECTOR(15 downto 0);
           packet_valid : out STD_LOGIC;
           packet_error : out STD_LOGIC
    );
end Packet_Decoder;


architecture architecture_dec of Packet_Decoder is

    type state_type is (WAIT_START, READ_MSB, READ_LSB, WAIT_STOP);

    signal state : state_type := WAIT_START;

    signal msb_reg, lsb_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal pkt_valid_int : STD_LOGIC := '0';
    signal pkt_err_int : STD_LOGIC := '0';

begin

    process(clk, resetn)
    begin
        if resetn = '0' then
            state <= WAIT_START;
            msb_reg <= (others => '0');
            lsb_reg <= (others => '0');
            pkt_valid_int <= '0';
            pkt_err_int <= '0';
        elsif rising_edge(clk) then
            pkt_valid_int <= '0';
            pkt_err_int <= '0';
            
            -- actionan doar cand primim un octet valid de la UART
            if data_valid = '1' then
                case state is
                    -- asteptam byte-ul de start xAA
                    when WAIT_START =>
                        if data_in = x"AA" then
                            state <= READ_MSB;
                        end if;
                    
                    -- salvam primul octet de date
                    when READ_MSB =>
                        msb_reg <= data_in;
                        state <= READ_LSB;
                    
                    -- salvam al doilea octet de date
                    when READ_LSB =>
                        lsb_reg <= data_in;
                        state <= WAIT_STOP;
                    
                    -- verificam daca pachetul se termina cu x55
                    when WAIT_STOP =>
                        if data_in = x"55" then
                            pkt_valid_int <= '1';
                        else
                            pkt_err_int <= '1';
                        end if;
                        state <= WAIT_START;
                        
                    when others =>
                        state <= WAIT_START;
                end case;
            end if;
        end if;
    end process;

    packet_out <= msb_reg & lsb_reg;
    packet_valid <= pkt_valid_int;
    packet_error <= pkt_err_int;

end architecture_dec;