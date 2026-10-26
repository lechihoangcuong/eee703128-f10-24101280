`timescale 1ns/1ps
`default_nettype none

// Concrete expected outputs for the complete TT pin interface.
// Stimulus at negedge; checks after following posedge/NBA update.
module f10_wrapper_tb;
    logic clk = 0;
    logic rst_n = 0, ena = 0;
    logic [7:0] ui_in = 0, uio_in = 0;
    wire [7:0] uo_out, uio_out, uio_oe;
    integer checks = 0, errors = 0, cases = 0, failed_cases = 0;
    integer before_errors = 0, before_checks = 0;
    integer csv, k;
    string current_case = "BOOT";
    time begin_time;

    tt_um_24101280_f10 dut (
        .ui_in(ui_in), .uo_out(uo_out), .uio_in(uio_in),
        .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );
    always #5 clk = ~clk;

    task automatic check(input logic condition, input string message);
        checks = checks + 1;
        if (condition !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL case=%s time=%0t %s inputs:rst=%b ena=%b ui=%h uio=%h out=%h", current_case, $time, message, rst_n, ena, ui_in, uio_in, uo_out);
        end
    endtask

    task automatic outputs(input logic [7:0] expected);
        check((^{uo_out, uio_out, uio_oe}) !== 1'bx, "all output bits known after reset");
        check(uo_out === expected, $sformatf("full uo_out expected=%h actual=%h", expected, uo_out));
        check(uio_out === 8'b0, "uio_out tied low");
        check(uio_oe === 8'b0, "all bidirectional pins are inputs");
    endtask

    task automatic step(
        input logic reset_n, enable, start, ack,
        input logic [7:0] deadline,
        input logic [5:0] unused_bits,
        input logic [3:0] expected_state,
        input logic expected_req, expected_done, expected_timeout
    );
        @(negedge clk);
        rst_n = reset_n;
        ena = enable;
        ui_in = deadline;
        uio_in = {unused_bits, start, ack};
        @(posedge clk);
        #1;
        outputs({1'b0, expected_state, expected_timeout, expected_done, expected_req});
    endtask

    task automatic begin_case(input string id, input string description);
        current_case = id;
        cases = cases + 1;
        before_errors = errors;
        before_checks = checks;
        begin_time = $time;
        $display("CASE_BEGIN %s %s", id, description);
    endtask

    task automatic end_case;
        if (errors != before_errors) failed_cases = failed_cases + 1;
        $display("CASE_END %s checks=%0d errors=%0d", current_case, checks-before_checks, errors-before_errors);
        $fdisplay(csv, "%s,%0t,%0t,%0d,%0d", current_case, begin_time, $time, checks-before_checks, errors-before_errors);
    endtask

    initial begin
        $dumpfile("f10_wrapper.vcd");
        $dumpvars(0, f10_wrapper_tb);
        csv = $fopen("wrapper_cases.csv", "w");
        if (!csv) $fatal(1, "cannot open wrapper case CSV");
        $fdisplay(csv, "case,start_ps,end_ps,checks,errors");

        begin_case("WR01", "synchronous initial reset and complete ports");
        step(0,1,1,1,8'hff,6'h3f,0,0,0,0);
        step(1,1,0,0,8'd4,0,0,0,0,0);
        end_case();

        begin_case("WR02", "ena zero suppresses new start");
        repeat (3) step(1,0,1,0,8'd4,6'h3f,0,0,0,0);
        end_case();

        begin_case("WR03", "normal four-phase handshake through mapped pins");
        step(1,1,1,0,8'd4,0,1,1,0,0);
        step(1,1,0,0,8'd4,0,1,1,0,0);
        step(1,1,0,1,8'd4,0,2,1,0,0);
        step(1,1,0,1,8'd4,0,3,0,0,0);
        step(1,1,0,0,8'd4,0,0,0,1,0);
        step(1,1,0,0,8'd4,0,0,0,0,0);
        end_case();

        begin_case("WR04", "no ACK expires after exactly three wait edges");
        step(1,1,1,0,8'd3,0,1,1,0,0);
        step(1,1,0,0,8'd3,0,1,1,0,0);
        step(1,1,0,0,8'd3,0,1,1,0,0);
        step(1,1,0,0,8'd3,0,0,0,0,1);
        step(1,1,0,0,8'd3,0,0,0,0,0);
        end_case();

        begin_case("WR05", "stale ACK blocks start; fresh start completes normally");
        repeat (2) step(1,1,1,1,8'd4,0,0,0,0,0);
        step(1,1,0,0,8'd4,0,0,0,0,0);
        step(1,1,1,0,8'd4,0,1,1,0,0);
        step(1,1,0,1,8'd4,0,2,1,0,0);
        step(1,1,0,1,8'd4,0,3,0,0,0);
        step(1,1,0,0,8'd4,0,0,0,1,0);
        step(1,1,0,0,8'd4,0,0,0,0,0);
        end_case();

        begin_case("WR06", "ena falling does not freeze a busy transaction");
        step(1,1,1,0,8'd4,0,1,1,0,0);
        step(1,0,1,0,8'd4,0,1,1,0,0);
        step(1,0,1,1,8'd4,0,2,1,0,0);
        step(1,0,1,1,8'd4,0,3,0,0,0);
        step(1,0,1,0,8'd4,0,0,0,1,0);
        step(1,0,1,0,8'd4,0,0,0,0,0);
        end_case();

        begin_case("WR07", "unused uio input bits do not change outputs");
        step(1,1,0,0,8'd4,6'h3f,0,0,0,0);
        step(1,1,0,0,8'd4,6'h15,0,0,0,0);
        step(1,1,0,0,8'd4,6'h2a,0,0,0,0);
        step(1,1,0,0,8'd4,6'h00,0,0,0,0);
        end_case();

        begin_case("WR08", "all eight timeout input bits preserved including bit seven");
        step(1,1,1,0,8'h80,0,1,1,0,0);
        for (k=0; k<127; k=k+1) step(1,1,0,0,8'h80,0,1,1,0,0);
        step(1,1,0,0,8'h80,0,0,0,0,1);
        step(1,1,0,0,8'h80,0,0,0,0,0);
        end_case();

        begin_case("WR09", "zero timeout becomes one wait edge");
        step(1,1,1,0,8'd0,0,1,1,0,0);
        step(1,1,0,0,8'd0,0,0,0,0,1);
        step(1,1,0,0,8'd0,0,0,0,0,0);
        end_case();

        begin_case("WR10", "stuck high ACK expires in wait-for-low phase");
        step(1,1,1,0,8'd2,0,1,1,0,0);
        step(1,1,0,1,8'd2,0,2,1,0,0);
        step(1,1,0,1,8'd2,0,3,0,0,0);
        step(1,1,0,1,8'd2,0,3,0,0,0);
        step(1,1,0,1,8'd2,0,0,0,0,1);
        step(1,1,0,0,8'd2,0,0,0,0,0);
        end_case();

        begin_case("WR11", "reset asserted between clocks acts only at next posedge");
        step(1,1,1,0,8'd4,0,1,1,0,0);
        #1 rst_n = 0;
        #1 outputs(8'h09); // state=1 and req=1: unchanged before next posedge.
        @(posedge clk); #1 outputs(8'h00);
        step(1,1,0,0,8'd4,0,0,0,0,0);
        end_case();

        $fclose(csv);
        $display("WRAPPER_SUMMARY cases=%0d failed_cases=%0d checks=%0d errors=%0d", cases, failed_cases, checks, errors);
        if (errors != 0 || failed_cases != 0 || checks == 0) $fatal(1, "wrapper test failed");
        $display("WRAPPER_ALL_TESTS_PASSED");
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "wrapper test timeout");
    end
endmodule

`default_nettype wire
