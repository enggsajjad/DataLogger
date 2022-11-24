library verilog;
use verilog.vl_types.all;
entity cu_rx is
    generic(
        idle            : integer := 0;
        chk_header      : integer := 1;
        nibble          : integer := 5;
        nib_done        : integer := 6;
        chk_cnt         : integer := 7;
        received1       : integer := 10;
        received0       : integer := 11;
        latch_header1   : integer := 12;
        latch_header0   : integer := 13
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        rx              : in     vl_logic;
        start_adr       : out    vl_logic_vector(23 downto 0);
        stop_adr        : out    vl_logic_vector(23 downto 0);
        status          : out    vl_logic_vector(23 downto 0);
        pkt_done        : out    vl_logic
    );
end cu_rx;
