library verilog;
use verilog.vl_types.all;
entity FLAGZERO_vlg_sample_tst is
    port(
        S               : in     vl_logic_vector(3 downto 0);
        sampler_tx      : out    vl_logic
    );
end FLAGZERO_vlg_sample_tst;
