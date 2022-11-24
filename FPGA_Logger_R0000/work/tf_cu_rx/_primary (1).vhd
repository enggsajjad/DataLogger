library verilog;
use verilog.vl_types.all;
entity tf_cu_rx is
    generic(
        xtl             : integer := 22118400;
        baud            : integer := 9600;
        nano            : integer := 1000000000;
        bit_time        : integer := 104166667
    );
end tf_cu_rx;
