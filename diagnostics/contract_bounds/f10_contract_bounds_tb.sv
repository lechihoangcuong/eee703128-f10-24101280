`timescale 1ns/1ps

// Supplemental diagnostics only: original 1035-case suite is unchanged.
// Drive at negedge, sample 1 ns after posedge/NBA. Legal ACK stays high
// until REQ has fallen. The last experiment deliberately violates that rule.
module f10_contract_bounds_tb;
    logic clk = 0;
    logic rst_n = 0, start = 0, ack = 0;
    logic [7:0] timeout_value = 0;
    wire req, done, timeout;
    wire [3:0] state;
    integer cycles = 0, checks = 0, errors = 0;
    integer valid_cases = 0, unsupported_observations = 0;
    integer csv;
    bit tracking = 0;
    string current_case = "RESET";
    time req_up_time, ack_up_time, req_down_time, ack_down_time;
    time sampled_edge_time;

    f10_handshake_controller dut (
        .clk(clk), .rst_n(rst_n), .start(start), .ack(ack),
        .timeout_value(timeout_value), .req(req), .done(done),
        .timeout(timeout), .state(state)
    );
    always #5 clk = ~clk;
    always @(posedge clk) cycles = cycles + 1;
    always @(posedge req) if (tracking) req_up_time = $time;
    always @(negedge req) if (tracking) req_down_time = $time;
    always @(posedge ack) if (tracking) ack_up_time = $time;
    always @(negedge ack) if (tracking) ack_down_time = $time;

    task automatic check(input logic condition, input string message);
        checks = checks + 1;
        if (condition !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL case=%s time=%0t cycle=%0d %s state=%b req=%b done=%b timeout=%b ack=%b",
                current_case, $time, cycles, message, state, req, done, timeout, ack);
        end
    endtask

    task automatic step(
        input logic s, a, input integer n,
        input logic [3:0] expected_state,
        input logic expected_req, expected_done, expected_timeout
    );
        @(negedge clk);
        start = s;
        ack = a;
        timeout_value = n[7:0];
        @(posedge clk);
        sampled_edge_time = $time;
        #1;
        check({state, req, done, timeout} ===
              {expected_state, expected_req, expected_done, expected_timeout},
              "concrete expected outputs at sampled edge");
        check((^{state, req, done, timeout}) !== 1'bx, "known outputs");
        check(!(done && timeout), "exclusive result events");
    endtask

    task automatic begin_tracking(input string id);
        current_case = id;
        req_up_time = 0;
        ack_up_time = 0;
        req_down_time = 0;
        ack_down_time = 0;
        tracking = 1;
    endtask

    task automatic valid_both_deadlines(input integer n);
        integer w, k, accepted_cycle, latency;
        time accepted_time, done_time;
        w = (n == 0) ? 1 : n;
        begin_tracking($sformatf("VALID_BOTH_DEADLINES_N%03d", n));
        step(1, 0, n, 1, 1, 0, 0);
        accepted_cycle = cycles;
        accepted_time = sampled_edge_time;
        for (k=1; k<w; k=k+1) step(0, 0, n, 1, 1, 0, 0);
        // ACK rises on the final permitted request-wait edge.
        step(0, 1, n, 2, 1, 0, 0);
        step(0, 1, n, 3, 0, 0, 0);
        // ACK stays high beyond REQ falling, then falls on the final
        // permitted return-wait edge. Both phase budgets are consumed.
        for (k=1; k<w; k=k+1) step(0, 1, n, 3, 0, 0, 0);
        step(0, 0, n, 0, 0, 1, 0);
        latency = cycles - accepted_cycle;
        done_time = sampled_edge_time;
        check(latency == 2*w+1, "accepted-start to DONE equals two budgets plus ACK_HIGH hold");
        check(req_up_time == accepted_time, "REQ rises on the accepted start edge");
        check(req_up_time < ack_up_time && ack_up_time < req_down_time &&
              req_down_time < ack_down_time && ack_down_time < done_time,
              "legal peer: four signal edges strictly ordered before DONE");
        check((done_time-accepted_time) == latency*10,
              "cycle latency agrees with raw edge timestamps at 10 ns clock");
        valid_cases = valid_cases + 1;
        $display("VALID_PEER_RESULT N=%0d W=%0d accepted_ns=%0d done_ns=%0d latency_cycles=%0d edge_ns=[%0d,%0d,%0d,%0d]",
            n,w,accepted_time,done_time,latency,req_up_time,ack_up_time,req_down_time,ack_down_time);
        $fdisplay(csv,"%s,VALID_PEER,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
            current_case,n,w,accepted_time,done_time,latency,
            req_up_time,ack_up_time,req_down_time,ack_down_time);
        tracking = 0;
        step(0, 0, n, 0, 0, 0, 0);
    endtask

    task automatic observe_unsupported_early_ack_drop;
        integer accepted_cycle, latency;
        time accepted_time, done_time;
        begin_tracking("EARLY_ACK_DROP");
        step(1, 0, 8, 1, 1, 0, 0);
        accepted_cycle = cycles;
        accepted_time = sampled_edge_time;
        step(0, 1, 8, 2, 1, 0, 0);
        check(req === 1'b1 && ack === 1'b1, "about to violate peer hold rule during ACK_HIGH");
        // Deliberate unsupported peer behavior: ACK falls at the next
        // negedge while REQ is still high, before core lowers REQ.
        step(0, 0, 8, 3, 0, 0, 0);
        check(ack_down_time < req_down_time, "experiment actually violated ACK hold ordering");
        step(0, 0, 8, 0, 0, 1, 0);
        latency = cycles - accepted_cycle;
        done_time = sampled_edge_time;
        check(latency == 3, "observed core completes despite unsupported early ACK drop");
        unsupported_observations = unsupported_observations + 1;
        $display("OBSERVED_UNSUPPORTED_PEER N=8 accepted_ns=%0d done_ns=%0d latency_cycles=%0d edge_ns=[%0d,%0d,%0d,%0d] ACK_fell_before_REQ: not a valid-protocol PASS",
            accepted_time,done_time,latency,req_up_time,ack_up_time,req_down_time,ack_down_time);
        $fdisplay(csv,"%s,OBSERVED_UNSUPPORTED_PEER,8,8,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
            current_case,accepted_time,done_time,latency,
            req_up_time,ack_up_time,req_down_time,ack_down_time);
        tracking = 0;
        step(0, 0, 8, 0, 0, 0, 0);
    endtask

    initial begin
        $dumpfile("f10_contract_bounds.vcd");
        $dumpvars(0, f10_contract_bounds_tb);
        csv = $fopen("diagnostic_cases.csv", "w");
        if (!csv) $fatal(1,"cannot open diagnostic CSV");
        $fdisplay(csv,"case_id,classification,N,W,accepted_ns,result_ns,latency_cycles,req_up_ns,ack_up_ns,req_down_ns,ack_down_ns");
        step(0, 0, 0, 0, 0, 0, 0);
        rst_n = 1;
        step(0, 0, 0, 0, 0, 0, 0);
        valid_both_deadlines(0);
        valid_both_deadlines(1);
        valid_both_deadlines(255);
        observe_unsupported_early_ack_drop();
        check(valid_cases == 3 && unsupported_observations == 1, "all four diagnostic experiments executed");
        check(checks > 0, "diagnostic checker executed");
        $fclose(csv);
        $display("DIAGNOSTIC_SUMMARY valid_cases=%0d unsupported_observations=%0d checks=%0d errors=%0d",
            valid_cases,unsupported_observations,checks,errors);
        if (errors != 0) $fatal(1,"diagnostic expectation mismatch");
        $display("DIAGNOSTIC_COMPLETED: valid-peer bounds measured; unsupported peer observation is a documented limit");
        $finish;
    end

    initial begin
        #100000;
        $fatal(1,"100 us diagnostic watchdog expired");
    end
endmodule
