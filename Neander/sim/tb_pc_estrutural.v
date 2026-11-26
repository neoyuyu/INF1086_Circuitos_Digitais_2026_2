`timescale 1ns / 1ps

module tb_pc_estrutural;

  reg        clk;
  reg        rstn;
  reg        cargaPC;
  reg        incrementaPC;
  reg  [7:0] data_in;
  wire [7:0] pc;

  integer pass_count;
  integer fail_count;
  integer i;
  reg [7:0] expected_pc;

  pc_estrutural dut (
      .clk         (clk),
      .rstn        (rstn),
      .cargaPC     (cargaPC),
      .incrementaPC(incrementaPC),
      .data_in     (data_in),
      .pc          (pc)
  );

  // 10 ns clock period (100 MHz)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  task check_pc;
    input [7:0] expected;
    input [8*64-1:0] label;
    begin
      if (pc !== expected) begin
        fail_count = fail_count + 1;
        $display(
            "FAIL [%0s] @ %0t: expected=0x%02h, got=0x%02h (rstn=%b cargaPC=%b incrementaPC=%b data_in=0x%02h)",
            label, $time, expected, pc, rstn, cargaPC, incrementaPC, data_in);
        $fatal(1, "Verification failed at %0s", label);
      end else begin
        pass_count = pass_count + 1;
      end
    end
  endtask

  // Drive synchronous inputs on negedge clk (when master latch qm is transparent)
  // and sample pc 1 ns after posedge clk (when slave latch q holds the value).
  task step_cycle;
    input next_carga;
    input next_inc;
    input [7:0] next_data;
    input [7:0] expected;
    input [8*64-1:0] label;
    begin
      @(negedge clk);
      cargaPC      = next_carga;
      incrementaPC = next_inc;
      data_in      = next_data;
      @(posedge clk);
      #1;
      check_pc(expected, label);
    end
  endtask

  initial begin
    $dumpfile("pc_estrutural.vcd");
    $dumpvars(0, tb_pc_estrutural);

    pass_count = 0;
    fail_count = 0;

    // ------------------------------------------------------------------
    // 1. Asynchronous Reset (rstn = 0)
    // ------------------------------------------------------------------
    $display("[1/5] Testing asynchronous reset (initial and mid-count)...");

    // 1a. Initial reset before any posedge clk, with control signals active
    rstn         = 1'b0;
    cargaPC      = 1'b1;
    incrementaPC = 1'b1;
    data_in      = 8'hAA;
    #1;
    check_pc(8'h00, "reset_init_async_immediate");

    // Verify reset holds pc == 0x00 across clock edges despite active inputs
    step_cycle(1'b1, 1'b0, 8'hFF, 8'h00, "reset_init_ignore_load");
    step_cycle(1'b0, 1'b1, 8'h55, 8'h00, "reset_init_ignore_inc");
    step_cycle(1'b1, 1'b1, 8'h0D, 8'h00, "reset_init_ignore_both");

    // Release reset cleanly on negedge clk
    @(negedge clk);
    rstn         = 1'b1;
    cargaPC      = 1'b0;
    incrementaPC = 1'b0;
    data_in      = 8'h00;
    @(posedge clk);
    #1;
    check_pc(8'h00, "reset_init_release_hold_00");

    // 1b. Mid-count async reset while clk == 0
    step_cycle(1'b1, 1'b0, 8'h3C, 8'h3C, "reset_mid_low_preload_3c");
    step_cycle(1'b0, 1'b1, 8'h00, 8'h3D, "reset_mid_low_inc_3d");

    @(negedge clk);
    #1;  // clk == 0
    cargaPC      = 1'b1;
    incrementaPC = 1'b1;
    data_in      = 8'hE7;
    rstn         = 1'b0;
    #1;  // still clk == 0, before posedge
    check_pc(8'h00, "reset_mid_clk_low_immediate");
    @(posedge clk);
    #1;
    check_pc(8'h00, "reset_mid_clk_low_posedge");

    // Release reset cleanly on negedge clk
    @(negedge clk);
    rstn         = 1'b1;
    cargaPC      = 1'b0;
    incrementaPC = 1'b0;
    data_in      = 8'h00;
    @(posedge clk);
    #1;
    check_pc(8'h00, "reset_mid_low_release_00");

    // 1c. Mid-count async reset while clk == 1
    step_cycle(1'b1, 1'b0, 8'hA5, 8'hA5, "reset_mid_high_preload_a5");
    step_cycle(1'b0, 1'b1, 8'h00, 8'hA6, "reset_mid_high_inc_a6");

    // Currently 1 ns after posedge clk (clk == 1)
    cargaPC      = 1'b1;
    incrementaPC = 1'b1;
    data_in      = 8'hFF;
    rstn         = 1'b0;
    #1;  // 2 ns after posedge (clk still 1)
    check_pc(8'h00, "reset_mid_clk_high_immediate");

    // Release rstn while clk == 1: slave latch holds q=0 and master latch holds qm=0
    rstn = 1'b1;
    #1;  // 3 ns after posedge (clk still 1)
    check_pc(8'h00, "reset_release_clk_high_stays_00");

    // At the upcoming negedge clk, qm sees cargaPC=1 & data_in=8'hFF -> captured at posedge
    @(posedge clk);
    #1;
    check_pc(8'hFF, "reset_post_high_release_next_load_ff");

    // Re-reset cleanly back to 0x00 for subsequent tests
    @(negedge clk);
    rstn         = 1'b0;
    cargaPC      = 1'b0;
    incrementaPC = 1'b0;
    data_in      = 8'h00;
    #1;
    check_pc(8'h00, "reset_before_hold_tests");
    @(negedge clk);
    rstn = 1'b1;
    @(posedge clk);
    #1;
    check_pc(8'h00, "reset_after_release_00");
    $display("      PASS: Asynchronous reset checks completed.");

    // ------------------------------------------------------------------
    // 2. Hold State (cargaPC = 0, incrementaPC = 0)
    // ------------------------------------------------------------------
    $display("[2/5] Testing hold state...");

    // Hold at 0x00 while data_in changes
    step_cycle(1'b0, 1'b0, 8'hFF, 8'h00, "hold_00_data_ff");
    step_cycle(1'b0, 1'b0, 8'h55, 8'h00, "hold_00_data_55");
    step_cycle(1'b0, 1'b0, 8'hAA, 8'h00, "hold_00_data_aa");

    // Load non-zero value 0xA5, then hold across multiple cycles with changing data_in
    step_cycle(1'b1, 1'b0, 8'hA5, 8'hA5, "hold_preload_a5");
    step_cycle(1'b0, 1'b0, 8'h00, 8'hA5, "hold_a5_data_00");
    step_cycle(1'b0, 1'b0, 8'hFF, 8'hA5, "hold_a5_data_ff");
    step_cycle(1'b0, 1'b0, 8'h5A, 8'hA5, "hold_a5_data_5a");
    step_cycle(1'b0, 1'b0, 8'h0D, 8'hA5, "hold_a5_data_0d");
    step_cycle(1'b0, 1'b0, 8'h12, 8'hA5, "hold_a5_data_12");
    $display("      PASS: Hold state checks completed.");

    // ------------------------------------------------------------------
    // 3. Parallel Load (cargaPC = 1, incrementaPC = 0)
    // ------------------------------------------------------------------
    $display("[3/5] Testing parallel load...");

    step_cycle(1'b1, 1'b0, 8'h00, 8'h00, "load_00_from_a5");
    step_cycle(1'b1, 1'b0, 8'h55, 8'h55, "load_55");
    step_cycle(1'b1, 1'b0, 8'hAA, 8'hAA, "load_aa");
    step_cycle(1'b1, 1'b0, 8'h0D, 8'h0D, "load_0d");
    step_cycle(1'b1, 1'b0, 8'hFF, 8'hFF, "load_ff");
    step_cycle(1'b1, 1'b0, 8'h00, 8'h00, "load_00_from_ff");
    step_cycle(1'b1, 1'b0, 8'h80, 8'h80, "load_80");
    step_cycle(1'b1, 1'b0, 8'h01, 8'h01, "load_01");
    step_cycle(1'b1, 1'b0, 8'h7F, 8'h7F, "load_7f");
    $display("      PASS: Parallel load checks completed.");

    // ------------------------------------------------------------------
    // 4. Increment (incrementaPC = 1, cargaPC = 0) & Carry Propagation
    // ------------------------------------------------------------------
    $display("[4/5] Testing sequential increment and ripple carry boundaries...");

    // Start sequentially from 0x00
    step_cycle(1'b1, 1'b0, 8'h00, 8'h00, "inc_start_00");

    // Full 256-step sweep (0x00 -> 0x01 -> ... -> 0xFF -> 0x00 -> 0x01)
    for (i = 0; i < 257; i = i + 1) begin
      expected_pc = (i + 1) & 8'hFF;
      // Vary data_in continuously to confirm cargaPC == 0 ignores data_in
      step_cycle(1'b0, 1'b1, expected_pc ^ 8'hA5, expected_pc, "inc_sweep");
      if (i == 8'h0F) begin
        $display("      Verified nibble carry boundary : 0x0F -> 0x%02h", pc);
      end else if (i == 8'h7F) begin
        $display("      Verified byte-half boundary    : 0x7F -> 0x%02h", pc);
      end else if (i == 8'hFF) begin
        $display("      Verified overflow wrap-around  : 0xFF -> 0x%02h", pc);
      end
    end

    // Targeted boundary checks via load-then-increment
    step_cycle(1'b1, 1'b0, 8'h0E, 8'h0E, "boundary_load_0e");
    step_cycle(1'b0, 1'b1, 8'h00, 8'h0F, "boundary_inc_0f");
    step_cycle(1'b0, 1'b1, 8'h00, 8'h10, "boundary_inc_0f_to_10");

    step_cycle(1'b1, 1'b0, 8'h7E, 8'h7E, "boundary_load_7e");
    step_cycle(1'b0, 1'b1, 8'h00, 8'h7F, "boundary_inc_7f");
    step_cycle(1'b0, 1'b1, 8'h00, 8'h80, "boundary_inc_7f_to_80");

    step_cycle(1'b1, 1'b0, 8'hFE, 8'hFE, "boundary_load_fe");
    step_cycle(1'b0, 1'b1, 8'h00, 8'hFF, "boundary_inc_ff");
    step_cycle(1'b0, 1'b1, 8'h00, 8'h00, "boundary_inc_ff_to_00");
    $display("      PASS: Sequential increment and carry propagation checks completed.");

    // ------------------------------------------------------------------
    // 5. Priority (cargaPC = 1 AND incrementaPC = 1)
    // ------------------------------------------------------------------
    $display("[5/5] Testing control priority (cargaPC overrides incrementaPC)...");

    step_cycle(1'b1, 1'b0, 8'h10, 8'h10, "prio_preload_10");
    step_cycle(1'b1, 1'b1, 8'h42, 8'h42, "prio_both_load_42_over_11");
    step_cycle(1'b1, 1'b1, 8'h00, 8'h00, "prio_both_load_00_over_43");
    step_cycle(1'b1, 1'b1, 8'hFF, 8'hFF, "prio_both_load_ff_over_01");
    step_cycle(1'b1, 1'b1, 8'h0D, 8'h0D, "prio_both_load_0d_over_00");
    step_cycle(1'b0, 1'b1, 8'h99, 8'h0E, "prio_release_carga_inc_0e");
    step_cycle(1'b1, 1'b1, 8'h0E, 8'h0E, "prio_both_load_0e_over_0f");
    step_cycle(1'b0, 1'b0, 8'h77, 8'h0E, "prio_end_hold_0e");
    $display("      PASS: Priority checks completed.");

    // ------------------------------------------------------------------
    // Summary
    // ------------------------------------------------------------------
    $display("============================================================");
    $display("pc_estrutural Testbench Summary:");
    $display("  Checks passed : %0d", pass_count);
    $display("  Checks failed : %0d", fail_count);
    $display("============================================================");
    if (fail_count != 0) begin
      $fatal(1, "FAIL: %0d check(s) failed.", fail_count);
    end
    $display("ALL TESTS PASSED!");
    $finish;
  end

endmodule
