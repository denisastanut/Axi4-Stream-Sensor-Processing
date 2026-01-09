-- RECEIVER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_receiver is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           rx : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR(7 downto 0);
           data_valid : out STD_LOGIC
    );
end UART_receiver;


architecture architecture_uart_receiver of UART_receiver is
    
    -- setam viteza: 100MHz si 9600 baud rate
    constant CLOCK_FREQ : integer := 100000000;
    constant BAUD_RATE  : integer := 9600;
    constant BAUD_TICKS : integer := CLOCK_FREQ / BAUD_RATE;

    -- starile FSM
    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;

    signal rx_sync : STD_LOGIC_VECTOR(1 downto 0) := "11";
    signal rx_reg : STD_LOGIC := '1';

    signal tick_count : integer range 0 to BAUD_TICKS := 0;
    signal bit_index : integer range 0 to 7 := 0;

    -- registre intermediare
    signal data_shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal data_out_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal data_valid_reg : STD_LOGIC := '0';

begin

    data_out <= data_out_reg;
    data_valid <= data_valid_reg;

    process(clk,resetn)
    begin
        -- reset asincron care aduce totul la starea initiala
        if resetn='0' then
            rx_sync <= "11";
            rx_reg <= '1';
            state <= IDLE;
            tick_count <= 0;
            bit_index <= 0;
            data_shift_reg <= (others=>'0');
            data_out_reg <= (others=>'0');
            data_valid_reg <= '0';

        elsif rising_edge(clk) then

            rx_sync(0) <= rx;
            rx_sync(1) <= rx_sync(0);
            rx_reg <= rx_sync(1);

            data_valid_reg <= '0';

            case state is

                -- asteptam ca RX sa treaca in '0' (Start Bit)
                when IDLE =>
                    tick_count <= 0;
                    bit_index <= 0;
                    if rx_reg='0' then
                        state <= START;
                    end if;

                -- verificarev bit de START
                when START =>
                    if tick_count = BAUD_TICKS/2 then
                        if rx_reg='0' then
                            tick_count <= 0;
                            state <= DATA; -- valid - citire date
                        else
                            state <= IDLE;
                        end if;
                    else
                        tick_count <= tick_count + 1;
                    end if;

                -- primim cei 8 biti de date
                when DATA =>
                    if tick_count = BAUD_TICKS then
                        tick_count <= 0;

                        data_shift_reg(bit_index) <= rx_reg;

                        if bit_index=7 then
                            state <= STOP; -- am terminat toti cei 8 biti
                        else
                            bit_index <= bit_index + 1;
                        end if;

                    else
                        tick_count <= tick_count + 1;
                    end if;

                -- asteptam bitul de STOP si validam datele primite
                when STOP =>
                    if tick_count = BAUD_TICKS then
                        tick_count <= 0;

                        data_out_reg <= data_shift_reg;
                        data_valid_reg <= '1';

                        state <= IDLE;
                    else
                        tick_count <= tick_count + 1;
                    end if;

            end case;
        end if;
    end process;

end architecture_uart_receiver;