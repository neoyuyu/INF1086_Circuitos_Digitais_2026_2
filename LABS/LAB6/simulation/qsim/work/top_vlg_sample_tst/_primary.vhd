library verilog;
use verilog.vl_types.all;
entity top_vlg_sample_tst is
    port(
        a               : in     vl_logic_vector(3 downto 0);
        b               : in     vl_logic_vector(3 downto 0);
        opsel           : in     vl_logic_vector(1 downto 0);
        sampler_tx      : out    vl_logic
    );
end top_vlg_sample_tst;
