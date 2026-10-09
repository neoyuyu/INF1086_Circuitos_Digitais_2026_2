library verilog;
use verilog.vl_types.all;
entity FFD_Divisor is
    port(
        Q               : out    vl_logic;
        RST             : in     vl_logic;
        CLK             : in     vl_logic
    );
end FFD_Divisor;
