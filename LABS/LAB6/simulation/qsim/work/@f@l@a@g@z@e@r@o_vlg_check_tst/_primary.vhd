library verilog;
use verilog.vl_types.all;
entity FLAGZERO_vlg_check_tst is
    port(
        flag_zero       : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end FLAGZERO_vlg_check_tst;
