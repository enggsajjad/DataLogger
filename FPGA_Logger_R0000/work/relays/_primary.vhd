library verilog;
use verilog.vl_types.all;
entity relays is
    generic(
        n               : integer := 15
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        run             : in     vl_logic;
        sel             : in     vl_logic;
        relayap         : out    vl_logic;
        relayan         : out    vl_logic;
        relaybp         : out    vl_logic;
        relaybn         : out    vl_logic
    );
end relays;
