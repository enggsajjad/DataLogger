library verilog;
use verilog.vl_types.all;
entity uart_rx is
    generic(
        crystal         : integer := 22118400;
        baud            : integer := 19200;
        start           : integer := 0;
        chk_enable      : integer := 1;
        inc_scount      : integer := 2;
        scount_delay    : integer := 3;
        enable_shift    : integer := 4;
        chk_scount      : integer := 5;
        inc_bcount      : integer := 6;
        bcount_delay    : integer := 7;
        chk_bcount      : integer := 8;
        rxdone          : integer := 9
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        rx              : in     vl_logic;
        rx_done         : out    vl_logic;
        dout_byte       : out    vl_logic_vector(7 downto 0)
    );
end uart_rx;
