library verilog;
use verilog.vl_types.all;
entity buttons is
    generic(
        idle            : integer := 0;
        chk_cnt1_end    : integer := 1;
        generate_ptick  : integer := 2;
        ptick_generated : integer := 3;
        chk_cnt2_end    : integer := 4;
        generate_ntick  : integer := 5;
        ntick_generated : integer := 6;
        n               : integer := 12
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        sw              : in     vl_logic_vector(4 downto 0);
        neg_tick        : out    vl_logic;
        pos_tick        : out    vl_logic;
        kcode           : out    vl_logic_vector(2 downto 0)
    );
end buttons;
