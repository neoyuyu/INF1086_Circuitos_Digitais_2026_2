library verilog;
use verilog.vl_types.all;
entity RCA_vlg_check_tst is
    port(
        Cout            : in     vl_logic;
        s               : in     vl_logic_vector(3 downto 0);
        sampler_rx      : in     vl_logic
    );
end RCA_vlg_check_tst;
