library verilog;
use verilog.vl_types.all;
entity DivisorFrequencia24 is
    port(
        Q               : out    vl_logic;
        RST             : in     vl_logic;
        CLK             : in     vl_logic
    );
end DivisorFrequencia24;
