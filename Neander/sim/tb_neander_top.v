`timescale 1ns / 1ps

module tb_neander_top;

    reg        clk_global;
    reg        sw_run_debug;
    reg        btn_step;
    reg        rstn;

    wire [7:0] out_pc;
    wire [7:0] out_acm;
    wire       a_1, b_1, c_1, d_1, e_1, f_1, g_1;
    wire       a_2, b_2, c_2, d_2, e_2, f_2, g_2;
    wire       a_3, b_3, c_3, d_3, e_3, f_3, g_3;
    wire       a_4, b_4, c_4, d_4, e_4, f_4, g_4;
    wire       led_n;
    wire       led_z;
    wire       led_hlt;
    wire       led_illegal;

    integer tests_passed;
    integer total_cycles;
    integer idx;

    neander_top dut (
        .clk_global   (clk_global),
        .sw_run_debug (sw_run_debug),
        .btn_step     (btn_step),
        .rstn         (rstn),
        .out_pc       (out_pc),
        .out_acm      (out_acm),
        .a_1 (a_1), .b_1 (b_1), .c_1 (c_1), .d_1 (d_1), .e_1 (e_1), .f_1 (f_1), .g_1 (g_1),
        .a_2 (a_2), .b_2 (b_2), .c_2 (c_2), .d_2 (d_2), .e_2 (e_2), .f_2 (f_2), .g_2 (g_2),
        .a_3 (a_3), .b_3 (b_3), .c_3 (c_3), .d_3 (d_3), .e_3 (e_3), .f_3 (f_3), .g_3 (g_3),
        .a_4 (a_4), .b_4 (b_4), .c_4 (c_4), .d_4 (d_4), .e_4 (e_4), .f_4 (f_4), .g_4 (g_4),
        .led_n        (led_n),
        .led_z        (led_z),
        .led_hlt      (led_hlt),
        .led_illegal  (led_illegal)
    );

    // 50 MHz global clock
    initial clk_global = 1'b0;
    always #10 clk_global = ~clk_global;

    // Active-low 7-segment pattern matching conversor_bcd.v: {segA..segG}
    function [6:0] expected_7seg;
        input [3:0] nibble;
        begin
            case (nibble)
                4'h0: expected_7seg = 7'b0000001;
                4'h1: expected_7seg = 7'b1001111;
                4'h2: expected_7seg = 7'b0010010;
                4'h3: expected_7seg = 7'b0000110;
                4'h4: expected_7seg = 7'b1001100;
                4'h5: expected_7seg = 7'b0100100;
                4'h6: expected_7seg = 7'b0100000;
                4'h7: expected_7seg = 7'b0001111;
                4'h8: expected_7seg = 7'b0000000;
                4'h9: expected_7seg = 7'b0000100;
                4'hA: expected_7seg = 7'b0001000;
                4'hB: expected_7seg = 7'b1100000;
                4'hC: expected_7seg = 7'b0110001;
                4'hD: expected_7seg = 7'b1000010;
                4'hE: expected_7seg = 7'b0110000;
                4'hF: expected_7seg = 7'b0111000;
            endcase
        end
    endfunction

    function [2:0] t_index;
        input [7:0] t_bus;
        begin
            case (t_bus)
                8'b0000_0001: t_index = 3'd0;
                8'b0000_0010: t_index = 3'd1;
                8'b0000_0100: t_index = 3'd2;
                8'b0000_1000: t_index = 3'd3;
                8'b0001_0000: t_index = 3'd4;
                8'b0010_0000: t_index = 3'd5;
                8'b0100_0000: t_index = 3'd6;
                8'b1000_0000: t_index = 3'd7;
                default:      t_index = 3'd0;
            endcase
        end
    endfunction

    task check_eq8;
        input [8*40-1:0] label;
        input [7:0]      actual;
        input [7:0]      expected;
        begin
            if (actual !== expected) begin
                $display("FAIL [%0s]: got 0x%02h (%b), expected 0x%02h (%b) at t=%0t",
                         label, actual, actual, expected, expected, $time);
                $fatal(1);
            end
        end
    endtask

    task check_eq7;
        input [8*40-1:0] label;
        input [6:0]      actual;
        input [6:0]      expected;
        begin
            if (actual !== expected) begin
                $display("FAIL [%0s]: got 7seg=%b, expected 7seg=%b at t=%0t",
                         label, actual, expected, $time);
                $fatal(1);
            end
        end
    endtask

    task check_eq1;
        input [8*40-1:0] label;
        input            actual;
        input            expected;
        begin
            if (actual !== expected) begin
                $display("FAIL [%0s]: got %b, expected %b at t=%0t",
                         label, actual, expected, $time);
                $fatal(1);
            end
        end
    endtask

    task check_7seg_displays;
        input [3:0] exp_pc_hi;  // HEX3 (a_2..g_2)
        input [3:0] exp_pc_lo;  // HEX2 (a_1..g_1)
        input [3:0] exp_ac_hi;  // HEX1 (a_4..g_4)
        input [3:0] exp_ac_lo;  // HEX0 (a_3..g_3)
        begin
            check_eq7("HEX3 out_pc[7:4] (a_2..g_2)",
                      {a_2, b_2, c_2, d_2, e_2, f_2, g_2}, expected_7seg(exp_pc_hi));
            check_eq7("HEX2 out_pc[3:0] (a_1..g_1)",
                      {a_1, b_1, c_1, d_1, e_1, f_1, g_1}, expected_7seg(exp_pc_lo));
            check_eq7("HEX1 out_acm[7:4] (a_4..g_4)",
                      {a_4, b_4, c_4, d_4, e_4, f_4, g_4}, expected_7seg(exp_ac_hi));
            check_eq7("HEX0 out_acm[3:0] (a_3..g_3)",
                      {a_3, b_3, c_3, d_3, e_3, f_3, g_3}, expected_7seg(exp_ac_lo));
        end
    endtask

    // Pulse btn_step (active-low in DEBUG mode -> clk=1 then clk=0 / clk_n=1)
    task step_cycle;
        begin
            #20;
            btn_step = 1'b0; // rising edge of clk
            #20;
            btn_step = 1'b1; // falling edge of clk / rising edge of clk_n (RAM clock)
            #1;
            total_cycles = total_cycles + 1;
            if (dut.unidade_controle.t == 8'b0000_1000) begin
                $display("  [cyc %03d | t%0d] DECODED op=0x%0h (RI=0x%02h) | PC=0x%02h AC=0x%02h N=%b Z=%b HLT=%b ILL=%b",
                         total_cycles, t_index(dut.unidade_controle.t),
                         dut.ri_out[7:4], dut.ri_out,
                         out_pc, out_acm, led_n, led_z, led_hlt, led_illegal);
            end
        end
    endtask

    task apply_reset;
        begin
            btn_step = 1'b1; // clk=0, clk_n=1
            rstn     = 1'b0;
            #25;
            rstn     = 1'b1;
            #5;
            check_eq8("reset out_pc",      out_pc,      8'h00);
            check_eq8("reset out_acm",     out_acm,     8'h00);
            check_eq1("reset led_n",       led_n,       1'b0);
            check_eq1("reset led_z",       led_z,       1'b0);
            check_eq1("reset led_hlt",     led_hlt,     1'b0);
            check_eq1("reset led_illegal", led_illegal, 1'b0);
            check_7seg_displays(4'h0, 4'h0, 4'h0, 4'h0);
        end
    endtask

    task run_until_hlt;
        input integer max_cycles;
        integer cyc;
        begin
            cyc = 0;
            while (!led_hlt && cyc < max_cycles) begin
                step_cycle();
                cyc = cyc + 1;
                if (led_illegal) begin
                    $display("FAIL: unexpected led_illegal=1 during normal execution at PC=0x%02h RI=0x%02h",
                             out_pc, dut.ri_out);
                    $fatal(1);
                end
            end
            if (!led_hlt) begin
                $display("FAIL: timeout waiting for led_hlt after %0d cycles (PC=0x%02h AC=0x%02h)",
                         max_cycles, out_pc, out_acm);
                $fatal(1);
            end
        end
    endtask

    task clear_ram;
        begin
            for (idx = 0; idx < 256; idx = idx + 1)
                dut.inst.mem[idx] = 8'h00;
        end
    endtask

    initial begin
        $dumpfile("neander_top.vcd");
        $dumpvars(0, tb_neander_top);

        sw_run_debug = 1'b1; // DEBUG mode (step by step via btn_step)
        btn_step     = 1'b1;
        rstn         = 1'b0;
        tests_passed = 0;
        total_cycles = 0;

        $display("====================================================================");
        $display("  NEANDER TOP-LEVEL INTEGRATION TESTBENCH (sw_run_debug=1)");
        $display("====================================================================");

        // ---------------------------------------------------------------------
        // Test 1: Real prog.mif execution (unequal operands 0x0A vs 0x0B)
        // ---------------------------------------------------------------------
        $display("\n--- Test 1: prog.mif unequal operands (0x80=0x0A, 0x82=0x0B) ---");
        apply_reset();
        // Verify prog.mif was actually loaded into ALTDPRAM (single & range entries)
        check_eq8("prog.mif mem[0x00]", dut.inst.mem[8'h00], 8'h20);
        check_eq8("prog.mif mem[0x0F]", dut.inst.mem[8'h0F], 8'hF0);
        check_eq8("prog.mif mem[0x10]", dut.inst.mem[8'h10], 8'h00);
        check_eq8("prog.mif mem[0x7F]", dut.inst.mem[8'h7F], 8'h00);
        check_eq8("prog.mif mem[0x80]", dut.inst.mem[8'h80], 8'h0A);
        check_eq8("prog.mif mem[0x82]", dut.inst.mem[8'h82], 8'h0B);
        check_eq8("prog.mif mem[0x84]", dut.inst.mem[8'h84], 8'h01);

        run_until_hlt(200);
        check_eq8("T1 out_pc",      out_pc,      8'h10);
        check_eq8("T1 out_acm",     out_acm,     8'h00);
        check_eq1("T1 led_n",       led_n,       1'b0);
        check_eq1("T1 led_z",       led_z,       1'b1);
        check_eq1("T1 led_hlt",     led_hlt,     1'b1);
        check_eq1("T1 led_illegal", led_illegal, 1'b0);
        check_7seg_displays(4'h1, 4'h0, 4'h0, 4'h0);

        // Confirm HLT freezes state across additional clock steps
        step_cycle();
        step_cycle();
        check_eq8("T1 freeze out_pc",  out_pc,  8'h10);
        check_eq8("T1 freeze out_acm", out_acm, 8'h00);
        check_eq1("T1 freeze led_hlt", led_hlt, 1'b1);

        $display("PASS Test 1: PC=0x%02h AC=0x%02h N=%b Z=%b HLT=%b ILL=%b HEX={1,0,0,0}",
                 out_pc, out_acm, led_n, led_z, led_hlt, led_illegal);
        tests_passed = tests_passed + 1;

        // ---------------------------------------------------------------------
        // Test 2: prog.mif with equal operands (mem[0x82] = 0x0A)
        // ---------------------------------------------------------------------
        $display("\n--- Test 2: prog.mif equal operands (0x80=0x0A, 0x82=0x0A) ---");
        apply_reset();
        dut.inst.mem[8'h82] = 8'h0A;

        run_until_hlt(200);
        check_eq8("T2 out_pc",      out_pc,      8'h10);
        check_eq8("T2 out_acm",     out_acm,     8'h01);
        check_eq1("T2 led_n",       led_n,       1'b0);
        check_eq1("T2 led_z",       led_z,       1'b0);
        check_eq1("T2 led_hlt",     led_hlt,     1'b1);
        check_eq1("T2 led_illegal", led_illegal, 1'b0);
        check_7seg_displays(4'h1, 4'h0, 4'h0, 4'h1);

        $display("PASS Test 2: PC=0x%02h AC=0x%02h N=%b Z=%b HLT=%b ILL=%b HEX={1,0,0,1}",
                 out_pc, out_acm, led_n, led_z, led_hlt, led_illegal);
        tests_passed = tests_passed + 1;

        // ---------------------------------------------------------------------
        // Test 3: Full ISA + STA RAM write-back + JN(not taken/taken)/OR/AND/NOP/JZ
        // ---------------------------------------------------------------------
        $display("\n--- Test 3: Full ISA + STA write-back + JN/OR/AND/NOP/JZ/ADD/HLT ---");
        apply_reset();
        clear_ram();

        // Program
        dut.inst.mem[8'h00] = 8'h00; // NOP
        dut.inst.mem[8'h01] = 8'h20; // LDA 0x80  -> AC = 0x55
        dut.inst.mem[8'h02] = 8'h80;
        dut.inst.mem[8'h03] = 8'h40; // OR  0x81  -> AC = 0x55 | 0x0F = 0x5F
        dut.inst.mem[8'h04] = 8'h81;
        dut.inst.mem[8'h05] = 8'h50; // AND 0x82  -> AC = 0x5F & 0x3C = 0x1C
        dut.inst.mem[8'h06] = 8'h82;
        dut.inst.mem[8'h07] = 8'h10; // STA 0x84  -> mem[0x84] <= 0x1C
        dut.inst.mem[8'h08] = 8'h84;
        dut.inst.mem[8'h09] = 8'h90; // JN  0x20  -> N=0, NOT taken (PC -> 0x0B)
        dut.inst.mem[8'h0A] = 8'h20;
        dut.inst.mem[8'h0B] = 8'h40; // OR  0x83  -> AC = 0x1C | 0x80 = 0x9C (N=1)
        dut.inst.mem[8'h0C] = 8'h83;
        dut.inst.mem[8'h0D] = 8'h90; // JN  0x12  -> N=1, TAKEN (PC -> 0x12)
        dut.inst.mem[8'h0E] = 8'h12;
        dut.inst.mem[8'h0F] = 8'h20; // (skipped trap) LDA 0x85
        dut.inst.mem[8'h10] = 8'h85;
        dut.inst.mem[8'h11] = 8'hF0; // (skipped trap) HLT
        dut.inst.mem[8'h12] = 8'h10; // STA 0x85  -> mem[0x85] <= 0x9C
        dut.inst.mem[8'h13] = 8'h85;
        dut.inst.mem[8'h14] = 8'h20; // LDA 0x86  -> AC = 0x00 (Z=1)
        dut.inst.mem[8'h15] = 8'h86;
        dut.inst.mem[8'h16] = 8'hA0; // JZ  0x1B  -> Z=1, TAKEN (PC -> 0x1B)
        dut.inst.mem[8'h17] = 8'h1B;
        dut.inst.mem[8'h18] = 8'h20; // (skipped trap) LDA 0x80
        dut.inst.mem[8'h19] = 8'h80;
        dut.inst.mem[8'h1A] = 8'hF0; // (skipped trap) HLT
        dut.inst.mem[8'h1B] = 8'h20; // LDA 0x84  -> read back STA #1 (AC = 0x1C)
        dut.inst.mem[8'h1C] = 8'h84;
        dut.inst.mem[8'h1D] = 8'h30; // ADD 0x85  -> add STA #2 (0x1C + 0x9C = 0xB8, N=1)
        dut.inst.mem[8'h1E] = 8'h85;
        dut.inst.mem[8'h1F] = 8'hF0; // HLT
        dut.inst.mem[8'h20] = 8'hF0; // (trap if JN at 0x09 wrongly taken)

        // Data
        dut.inst.mem[8'h80] = 8'h55;
        dut.inst.mem[8'h81] = 8'h0F;
        dut.inst.mem[8'h82] = 8'h3C;
        dut.inst.mem[8'h83] = 8'h80;
        dut.inst.mem[8'h84] = 8'h00; // target for STA #1
        dut.inst.mem[8'h85] = 8'hAA; // target for STA #2 (overwritten from 0xAA to 0x9C)
        dut.inst.mem[8'h86] = 8'h00;

        run_until_hlt(250);
        check_eq8("T3 STA mem[0x84]", dut.inst.mem[8'h84], 8'h1C);
        check_eq8("T3 STA mem[0x85]", dut.inst.mem[8'h85], 8'h9C);
        check_eq8("T3 out_pc",        out_pc,              8'h20);
        check_eq8("T3 out_acm",       out_acm,             8'hB8);
        check_eq1("T3 led_n",         led_n,               1'b1);
        check_eq1("T3 led_z",         led_z,               1'b0);
        check_eq1("T3 led_hlt",       led_hlt,             1'b1);
        check_eq1("T3 led_illegal",   led_illegal,         1'b0);
        check_7seg_displays(4'h2, 4'h0, 4'hB, 4'h8);

        $display("PASS Test 3: PC=0x%02h AC=0x%02h N=%b Z=%b HLT=%b mem[0x84]=0x%02h mem[0x85]=0x%02h",
                 out_pc, out_acm, led_n, led_z, led_hlt,
                 dut.inst.mem[8'h84], dut.inst.mem[8'h85]);
        tests_passed = tests_passed + 1;

        // ---------------------------------------------------------------------
        // Test 4: illegal_op check (opcode 0x70 -> led_illegal == 1)
        // ---------------------------------------------------------------------
        $display("\n--- Test 4: illegal_op detection (opcode 0x70) ---");
        apply_reset();
        clear_ram();
        dut.inst.mem[8'h00] = 8'h70; // Illegal opcode 4'h7

        // 3 cycles: t0->t1 (REM<-0), t1->t2 (RDM<-0x70, PC<-1), t2->t3 (RI<-0x70)
        step_cycle();
        step_cycle();
        step_cycle();

        check_eq8("T4 out_pc",      out_pc,      8'h01);
        check_eq1("T4 led_illegal", led_illegal, 1'b1);
        check_eq1("T4 led_hlt",     led_hlt,     1'b0);

        $display("PASS Test 4: PC=0x%02h RI=0x%02h led_illegal=%b led_hlt=%b",
                 out_pc, dut.ri_out, led_illegal, led_hlt);
        apply_reset();
        tests_passed = tests_passed + 1;

        $display("\n====================================================================");
        $display("  ALL %0d TESTS PASSED (total stepped cycles = %0d)", tests_passed, total_cycles);
        $display("====================================================================");
        $finish;
    end

endmodule
