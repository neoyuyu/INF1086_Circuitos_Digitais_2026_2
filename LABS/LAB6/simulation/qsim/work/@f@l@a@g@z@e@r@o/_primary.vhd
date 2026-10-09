library verilog;
use verilog.vl_types.all;
entity FLAGZERO is
    port(
        flag_zero       : out    vl_logic;
        S               : in     vl_logic_vector(3 downto 0)
    );
end FLAGZERO;
