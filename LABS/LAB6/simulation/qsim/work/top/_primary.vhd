library verilog;
use verilog.vl_types.all;
entity top is
    port(
        a               : in     vl_logic_vector(3 downto 0);
        b               : in     vl_logic_vector(3 downto 0);
        opsel           : in     vl_logic_vector(1 downto 0);
        flagn           : out    vl_logic;
        flagz           : out    vl_logic;
        segA            : out    vl_logic;
        segB            : out    vl_logic;
        segC            : out    vl_logic;
        segD            : out    vl_logic;
        segE            : out    vl_logic;
        segF            : out    vl_logic;
        segG            : out    vl_logic
    );
end top;
