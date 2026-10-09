library verilog;
use verilog.vl_types.all;
entity top_vlg_check_tst is
    port(
        flagn           : in     vl_logic;
        flagz           : in     vl_logic;
        segA            : in     vl_logic;
        segB            : in     vl_logic;
        segC            : in     vl_logic;
        segD            : in     vl_logic;
        segE            : in     vl_logic;
        segF            : in     vl_logic;
        segG            : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end top_vlg_check_tst;
