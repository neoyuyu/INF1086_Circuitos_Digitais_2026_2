// Behavioral simulation model of Altera ALTDPRAM megafunction
// Matches the parameters and port interface used in schematics/neander_top.bdf.
`timescale 1ns / 1ps

module ALTDPRAM #(
    parameter FILE           = "prog.mif",
    parameter INDATA_ACLR    = "ON",
    parameter INDATA_REG     = "INCLOCK",
    parameter NUMWORDS       = 256,
    parameter OUTDATA_ACLR   = "ON",
    parameter OUTDATA_REG    = "UNREGISTERED",
    parameter RDADDRESS_ACLR = "ON",
    parameter RDADDRESS_REG  = "OUTCLOCK",
    parameter RDCONTROL_ACLR = "ON",
    parameter RDCONTROL_REG  = "OUTCLOCK",
    parameter USE_EAB        = "ON",
    parameter WIDTH          = 8,
    parameter WIDTHAD        = 8,
    parameter WRADDRESS_ACLR = "ON",
    parameter WRADDRESS_REG  = "INCLOCK",
    parameter WRCONTROL_ACLR = "ON",
    parameter WRCONTROL_REG  = "INCLOCK"
) (
    input  wire               inclocken,
    input  wire               inclock,
    input  wire [WIDTHAD-1:0] rdaddress,
    input  wire               rden,
    input  wire [WIDTHAD-1:0] wraddress,
    input  wire [WIDTH-1:0]   data,
    input  wire               outclock,
    input  wire               outclocken,
    input  wire               wren,
    input  wire               aclr,
    output wire [WIDTH-1:0]   q
);

    reg [WIDTH-1:0] mem [0:NUMWORDS-1];

    // Registered port signals
    reg [WIDTHAD-1:0] rdaddr_outclk;
    reg [WIDTHAD-1:0] rdaddr_inclk;
    reg               rden_outclk;
    reg               rden_inclk;

    reg [WIDTHAD-1:0] wraddr_inclk;
    reg [WIDTH-1:0]   data_inclk;
    reg               wren_inclk;

    reg [WIDTH-1:0]   q_outclk;
    reg [WIDTH-1:0]   q_latch;

    // -------------------------------------------------------------------------
    // MIF Parser (supports single entries "AA : DD;" and ranges "[AA..BB] : DD;")
    // -------------------------------------------------------------------------
    integer mif_unget;

    task mif_init_reader;
        begin
            mif_unget = -2;
        end
    endtask

    task mif_getc;
        input  integer fd;
        output integer ch;
        begin
            if (mif_unget != -2) begin
                ch        = mif_unget;
                mif_unget = -2;
            end else begin
                ch = $fgetc(fd);
            end
        end
    endtask

    task mif_ungetc;
        input integer ch;
        begin
            mif_unget = ch;
        end
    endtask

    function [7:0] to_upper;
        input [7:0] c;
        begin
            if (c >= "a" && c <= "z")
                to_upper = c - 8'd32;
            else
                to_upper = c;
        end
    endfunction

    function integer is_alnum_or_us;
        input integer ch;
        begin
            if (ch < 0)
                is_alnum_or_us = 0;
            else if ((ch >= "0" && ch <= "9") ||
                     (ch >= "A" && ch <= "Z") ||
                     (ch >= "a" && ch <= "z") ||
                     (ch == "_"))
                is_alnum_or_us = 1;
            else
                is_alnum_or_us = 0;
        end
    endfunction

    function integer digit_val;
        input integer ch;
        input integer radix;
        integer d;
        begin
            if (ch >= "0" && ch <= "9")
                d = ch - "0";
            else if (ch >= "A" && ch <= "F")
                d = ch - "A" + 10;
            else if (ch >= "a" && ch <= "f")
                d = ch - "a" + 10;
            else
                d = -1;

            if (d >= 0 && d < radix)
                digit_val = d;
            else
                digit_val = -1;
        end
    endfunction

    task mif_skip_ws_comments;
        input  integer fd;
        output integer ch;
        integer c1, c2;
        reg     done;
        begin
            done = 1'b0;
            ch   = -1;
            while (!done) begin
                mif_getc(fd, c1);
                if (c1 < 0) begin
                    ch   = -1;
                    done = 1'b1;
                end else if (c1 == " " || c1 == "\t" || c1 == "\n" || c1 == "\r") begin
                    // skip whitespace
                end else if (c1 == "%") begin
                    // block comment % ... %
                    c2 = 0;
                    while (c2 >= 0 && c2 != "%")
                        mif_getc(fd, c2);
                end else if (c1 == "-") begin
                    mif_getc(fd, c2);
                    if (c2 == "-") begin
                        // line comment -- ... \n
                        while (c2 >= 0 && c2 != "\n")
                            mif_getc(fd, c2);
                    end else begin
                        if (c2 >= 0)
                            mif_ungetc(c2);
                        ch   = c1;
                        done = 1'b1;
                    end
                end else begin
                    ch   = c1;
                    done = 1'b1;
                end
            end
        end
    endtask

    task mif_read_word;
        input  integer         fd;
        output [8*32-1:0]      word;
        output integer         length;
        integer ch;
        reg     reading;
        begin
            word   = {32{8'h00}};
            length = 0;
            mif_skip_ws_comments(fd, ch);
            if (ch >= 0 && is_alnum_or_us(ch)) begin
                reading = 1'b1;
                while (reading) begin
                    word   = {word[8*31-1:0], to_upper(ch[7:0])};
                    length = length + 1;
                    mif_getc(fd, ch);
                    if (!is_alnum_or_us(ch)) begin
                        if (ch >= 0)
                            mif_ungetc(ch);
                        reading = 1'b0;
                    end
                end
            end else if (ch >= 0) begin
                mif_ungetc(ch);
            end
        end
    endtask

    task mif_read_number;
        input  integer fd;
        input  integer radix;
        output integer val;
        output integer ok;
        integer ch, d;
        reg     reading;
        begin
            val = 0;
            ok  = 0;
            mif_skip_ws_comments(fd, ch);
            if (ch >= 0 && digit_val(ch, radix) >= 0) begin
                reading = 1'b1;
                while (reading) begin
                    d = digit_val(ch, radix);
                    if (d >= 0) begin
                        val = val * radix + d;
                        ok  = 1;
                        mif_getc(fd, ch);
                    end else begin
                        if (ch >= 0)
                            mif_ungetc(ch);
                        reading = 1'b0;
                    end
                end
            end else if (ch >= 0) begin
                mif_ungetc(ch);
            end
        end
    endtask

    function integer radix_from_word;
        input [8*32-1:0] w;
        begin
            if (w == "HEX")
                radix_from_word = 16;
            else if (w == "BIN")
                radix_from_word = 2;
            else if (w == "OCT")
                radix_from_word = 8;
            else
                radix_from_word = 10;
        end
    endfunction

    task parse_mif_fd;
        input integer fd;
        integer addr_radix, data_radix;
        integer ch, tok_len, ok;
        integer addr, start_addr, end_addr, val, i;
        reg [8*32-1:0] tok;
        reg in_content, parsing, row_done;
        begin
            addr_radix = 16;
            data_radix = 16;
            in_content = 1'b0;
            parsing    = 1'b1;
            mif_init_reader();

            // Header phase until CONTENT BEGIN
            while (parsing && !in_content) begin
                mif_skip_ws_comments(fd, ch);
                if (ch < 0) begin
                    parsing = 1'b0;
                end else if (is_alnum_or_us(ch)) begin
                    mif_ungetc(ch);
                    mif_read_word(fd, tok, tok_len);
                    if (tok == "ADDRESS_RADIX") begin
                        mif_skip_ws_comments(fd, ch); // '='
                        mif_read_word(fd, tok, tok_len);
                        addr_radix = radix_from_word(tok);
                    end else if (tok == "DATA_RADIX") begin
                        mif_skip_ws_comments(fd, ch); // '='
                        mif_read_word(fd, tok, tok_len);
                        data_radix = radix_from_word(tok);
                    end else if (tok == "CONTENT") begin
                        mif_read_word(fd, tok, tok_len); // BEGIN
                        if (tok == "BEGIN")
                            in_content = 1'b1;
                    end
                end
            end

            // Content phase
            while (parsing && in_content) begin
                mif_skip_ws_comments(fd, ch);
                if (ch < 0) begin
                    parsing = 1'b0;
                end else if (ch == "[") begin
                    // Range entry: [start..end] : val;
                    mif_read_number(fd, addr_radix, start_addr, ok);
                    if (!ok) begin
                        $display("ALTDPRAM ERROR: invalid range start in %s", FILE);
                        $fatal(1);
                    end
                    mif_skip_ws_comments(fd, ch); // '.'
                    mif_skip_ws_comments(fd, ch); // '.'
                    mif_read_number(fd, addr_radix, end_addr, ok);
                    if (!ok) begin
                        $display("ALTDPRAM ERROR: invalid range end in %s", FILE);
                        $fatal(1);
                    end
                    mif_skip_ws_comments(fd, ch); // ']'
                    mif_skip_ws_comments(fd, ch); // ':'
                    mif_read_number(fd, data_radix, val, ok);
                    if (!ok) begin
                        $display("ALTDPRAM ERROR: invalid range data in %s", FILE);
                        $fatal(1);
                    end
                    for (i = start_addr; i <= end_addr; i = i + 1) begin
                        if (i >= 0 && i < NUMWORDS)
                            mem[i] = val[WIDTH-1:0];
                    end
                    mif_skip_ws_comments(fd, ch); // ';'
                end else if (is_alnum_or_us(ch)) begin
                    mif_ungetc(ch);
                    // Check for END keyword vs hex/dec address
                    mif_read_word(fd, tok, tok_len);
                    if (tok == "END") begin
                        parsing = 1'b0;
                    end else begin
                        // Convert tok as address under addr_radix
                        addr = 0;
                        ok   = 1;
                        for (i = tok_len - 1; i >= 0; i = i - 1) begin
                            val = digit_val((tok >> (i * 8)) & 8'hFF, addr_radix);
                            if (val < 0)
                                ok = 0;
                            else
                                addr = addr * addr_radix + val;
                        end
                        if (!ok) begin
                            $display("ALTDPRAM ERROR: invalid address token in %s", FILE);
                            $fatal(1);
                        end
                        mif_skip_ws_comments(fd, ch); // ':'
                        if (ch != ":") begin
                            $display("ALTDPRAM ERROR: expected ':' after address 0x%0h in %s", addr, FILE);
                            $fatal(1);
                        end
                        row_done = 1'b0;
                        while (!row_done) begin
                            mif_skip_ws_comments(fd, ch);
                            if (ch < 0 || ch == ";") begin
                                row_done = 1'b1;
                            end else begin
                                mif_ungetc(ch);
                                mif_read_number(fd, data_radix, val, ok);
                                if (!ok) begin
                                    $display("ALTDPRAM ERROR: invalid data value at address 0x%0h in %s", addr, FILE);
                                    $fatal(1);
                                end
                                if (addr >= 0 && addr < NUMWORDS)
                                    mem[addr] = val[WIDTH-1:0];
                                addr = addr + 1;
                            end
                        end
                    end
                end
            end
        end
    endtask

    integer idx, mif_fd;
    initial begin
        for (idx = 0; idx < NUMWORDS; idx = idx + 1)
            mem[idx] = {WIDTH{1'b0}};

        rdaddr_outclk = {WIDTHAD{1'b0}};
        rdaddr_inclk  = {WIDTHAD{1'b0}};
        rden_outclk   = 1'b0;
        rden_inclk    = 1'b0;
        wraddr_inclk  = {WIDTHAD{1'b0}};
        data_inclk    = {WIDTH{1'b0}};
        wren_inclk    = 1'b0;
        q_outclk      = {WIDTH{1'b0}};
        q_latch       = {WIDTH{1'b0}};

        if (FILE != "" && FILE != "UNUSED") begin
            mif_fd = $fopen(FILE, "r");
            if (mif_fd == 0)
                mif_fd = $fopen({"../", FILE}, "r");
            if (mif_fd == 0) begin
                $display("ALTDPRAM ERROR: could not open initialization file '%s' or '../%s'", FILE, FILE);
                $fatal(1);
            end
            parse_mif_fd(mif_fd);
            $fclose(mif_fd);
        end
    end

    // -------------------------------------------------------------------------
    // Write port registers & synchronous write (INCLOCK domain)
    // -------------------------------------------------------------------------
    always @(posedge inclock or posedge aclr) begin
        if (aclr) begin
            if (WRADDRESS_ACLR == "ON") wraddr_inclk <= {WIDTHAD{1'b0}};
            if (INDATA_ACLR    == "ON") data_inclk   <= {WIDTH{1'b0}};
            if (WRCONTROL_ACLR == "ON") wren_inclk   <= 1'b0;
            if (RDADDRESS_ACLR == "ON") rdaddr_inclk <= {WIDTHAD{1'b0}};
            if (RDCONTROL_ACLR == "ON") rden_inclk   <= 1'b0;
        end else if (inclocken) begin
            wraddr_inclk <= wraddress;
            data_inclk   <= data;
            wren_inclk   <= wren;
            rdaddr_inclk <= rdaddress;
            rden_inclk   <= rden;

            if (WRCONTROL_REG == "INCLOCK" && wren)
                mem[(WRADDRESS_REG == "INCLOCK") ? wraddress : wraddr_inclk]
                    <= (INDATA_REG == "INCLOCK") ? data : data_inclk;
        end
    end

    generate
        if (WRCONTROL_REG == "UNREGISTERED") begin : gen_unreg_write
            always @(wren or wraddress or data or aclr) begin
                if (wren && !aclr)
                    mem[wraddress] = data;
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Read port registers (OUTCLOCK domain) & output stage
    // -------------------------------------------------------------------------
    always @(posedge outclock or posedge aclr) begin
        if (aclr) begin
            if (RDADDRESS_ACLR == "ON") rdaddr_outclk <= {WIDTHAD{1'b0}};
            if (RDCONTROL_ACLR == "ON") rden_outclk   <= 1'b0;
        end else if (outclocken) begin
            rdaddr_outclk <= rdaddress;
            rden_outclk   <= rden;
        end
    end

    wire [WIDTHAD-1:0] rdaddr_eff =
        (RDADDRESS_REG == "OUTCLOCK") ? rdaddr_outclk :
        (RDADDRESS_REG == "INCLOCK")  ? rdaddr_inclk  : rdaddress;

    wire rden_eff =
        (RDCONTROL_REG == "OUTCLOCK") ? rden_outclk :
        (RDCONTROL_REG == "INCLOCK")  ? rden_inclk  : rden;

    wire [WIDTH-1:0] mem_rdata = mem[rdaddr_eff];

    always @(mem_rdata or rden_eff or aclr) begin
        if ((OUTDATA_ACLR == "ON") && aclr)
            q_latch = {WIDTH{1'b0}};
        else if (rden_eff)
            q_latch = mem_rdata;
    end

    always @(posedge outclock or posedge aclr) begin
        if (aclr) begin
            if (OUTDATA_ACLR == "ON")
                q_outclk <= {WIDTH{1'b0}};
        end else if (outclocken) begin
            q_outclk <= q_latch;
        end
    end

    assign q = (OUTDATA_REG == "OUTCLOCK") ? q_outclk : q_latch;

endmodule
