library verilog;
use verilog.vl_types.all;
entity adc is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        drdy            : out    vl_logic;
        dataout         : out    vl_logic_vector(15 downto 0);
        sdin            : in     vl_logic;
        ndrdy           : in     vl_logic;
        sclk            : out    vl_logic;
        ncs             : out    vl_logic
    );
end adc;
