`timescale 1ns/1ps

// Independent, cycle-by-cycle checker for the supplied F10 core contract.
// Drive at falling edges; sample one nanosecond after rising edges, after NBA.
// The model uses a remaining-cycle deadline, never DUT state/internal registers.
module f10_tb_selfcheck;
    logic clk = 0;
    logic rst_n = 0, start = 0, ack = 0;
    logic [7:0] timeout_value = 0;
    wire req, done, timeout;
    wire [3:0] state;

    f10_handshake_controller dut (
        .clk(clk), .rst_n(rst_n), .start(start), .ack(ack),
        .timeout_value(timeout_value), .req(req), .done(done),
        .timeout(timeout), .state(state)
    );
    always #5 clk = ~clk;

    integer model_phase = 0;
    integer model_budget = 1;
    integer remaining = 0;
    logic model_req = 0, model_done = 0, model_timeout = 0;
    integer previous_phase = 0;
    logic sampled_ack = 0;
    logic previous_done = 0, previous_timeout = 0;
    integer busy_age = 0;

    integer cycles = 0, checks = 0, errors = 0;
    integer cases = 0, failed_cases = 0;
    integer case_start_cycle = 0, case_start_checks = 0, case_start_errors = 0;
    integer csv;
    string case_id = "BOOT";
    string case_description = "initial reset";
    time case_start_time;
    integer n, k, phase;
    integer random_resets = 0;
    logic [31:0] rng = 32'hF1002026;

    task automatic check(input logic condition, input string message);
        begin
            checks = checks + 1;
            if (condition !== 1'b1) begin
                errors = errors + 1;
                $display("FAIL case=%s cycle=%0d time=%0t: %s", case_id, cycles, $time, message);
                $display("  inputs rst_n=%b start=%b ack=%b N=%0d; DUT state=%b req=%b done=%b timeout=%b; expected phase=%0d req=%b done=%b timeout=%b remaining=%0d",
                    rst_n, start, ack, timeout_value, state, req, done, timeout,
                    model_phase, model_req, model_done, model_timeout, remaining);
                if (errors >= 20) $fatal(1, "Stopping after 20 failures");
            end
        end
    endtask

    always @(posedge clk) begin
        cycles = cycles + 1;
        previous_phase = model_phase;
        sampled_ack = ack;
        model_done = 0;
        model_timeout = 0;

        if (!rst_n) begin
            model_phase = 0;
            model_budget = 1;
            remaining = 0;
            busy_age = 0;
        end else begin
            case (model_phase)
                0: begin
                    remaining = 0;
                    if (start && !ack) begin
                        model_budget = (timeout_value == 0) ? 1 : timeout_value;
                        remaining = model_budget;
                        model_phase = 1;
                    end
                end
                1: begin
                    if (ack) begin
                        model_phase = 2;
                        remaining = 0;
                    end else if (remaining <= 1) begin
                        model_timeout = 1;
                        model_phase = 0;
                        remaining = 0;
                    end else remaining = remaining - 1;
                end
                2: begin
                    model_phase = 3;
                    remaining = model_budget;
                end
                3: begin
                    if (!ack) begin
                        model_done = 1;
                        model_phase = 0;
                        remaining = 0;
                    end else if (remaining <= 1) begin
                        model_timeout = 1;
                        model_phase = 0;
                        remaining = 0;
                    end else remaining = remaining - 1;
                end
                default: $fatal(1, "Reference model illegal phase");
            endcase
            if (model_phase == 0) busy_age = 0;
            else busy_age = busy_age + 1;
        end
        model_req = (model_phase == 1 || model_phase == 2);

        #1;
        check((^{state, req, done, timeout}) !== 1'bx, "Outputs must not contain X/Z after sampled reset");
        check(state === model_phase[3:0], "State differs from independent reference");
        check(req === model_req, "REQ differs from independent reference");
        check(done === model_done, "DONE differs from independent reference");
        check(timeout === model_timeout, "TIMEOUT differs from independent reference");
        check(state <= 4'd3, "State must be one of the four legal encodings");
        check(!(done && timeout), "DONE and TIMEOUT must be mutually exclusive");
        check(!(done && previous_done), "DONE pulse must last only one cycle");
        check(!(timeout && previous_timeout), "TIMEOUT pulse must last only one cycle");
        check(!(state == 0 && req), "REQ must be low in IDLE");
        check(!done || (rst_n && previous_phase == 3 && sampled_ack === 1'b0),
              "DONE requires sampled ACK-low in WAIT_ACK_LOW");
        check(busy_age <= 512, "Transaction must terminate within 512 sampled cycles");
        previous_done = done;
        previous_timeout = timeout;
    end

    task automatic cycle(input logic s, input logic a, input integer value, input logic reset_n);
        begin
            @(negedge clk);
            start = s;
            ack = a;
            timeout_value = value[7:0];
            rst_n = reset_n;
            @(posedge clk);
            #2; // Checker samples at +1 ns, then control returns at +2 ns.
        end
    endtask

    task automatic begin_case(input string id, input string description);
        begin
            case_id = id;
            case_description = description;
            case_start_cycle = cycles;
            case_start_checks = checks;
            case_start_errors = errors;
            case_start_time = $time;
        end
    endtask

    task automatic end_case;
        begin
            cases = cases + 1;
            if (errors != case_start_errors) failed_cases = failed_cases + 1;
            $fdisplay(csv, "%s,%s,%0d,%0d,%0d,%0d,%0d,%s", case_id, case_description,
                case_start_time, $time, cycles - case_start_cycle, checks - case_start_checks,
                errors - case_start_errors, (errors == case_start_errors) ? "PASS" : "FAIL");
            if (cases <= 10 || (errors != case_start_errors))
                $display("CASE %s %s time_ns=[%0d..%0d] cycles=%0d checks=%0d errors=%0d",
                    case_id, (errors == case_start_errors) ? "PASS" : "FAIL",
                    case_start_time, $time, cycles - case_start_cycle,
                    checks - case_start_checks, errors - case_start_errors);
        end
    endtask

    task automatic idle_clear;
        begin
            cycle(0, 0, 0, 1);
            check({state, req, done, timeout} === 7'b0, "Idle recovery and result pulse clearing");
        end
    endtask

    task automatic complete_handshake(input integer value, input integer delay_up, input integer delay_down);
        integer j;
        begin
            cycle(1, 0, value, 1);
            check(state === 4'd1 && req === 1'b1, "Phase 1 REQ-high");
            for (j = 0; j < delay_up; j = j + 1) cycle(0, 0, value, 1);
            cycle(0, 1, value, 1);
            check(state === 4'd2 && req === 1'b1, "Phase 2 ACK-high accepted while REQ stays high");
            cycle(0, 1, value, 1);
            check(state === 4'd3 && req === 1'b0, "Phase 3 REQ-low");
            for (j = 0; j < delay_down; j = j + 1) cycle(0, 1, value, 1);
            cycle(0, 0, value, 1);
            check(done === 1'b1 && timeout === 1'b0, "Phase 4 ACK-low and DONE");
        end
    endtask

    task automatic synchronous_reset_between_edges;
        logic [6:0] before_reset;
        begin
            @(negedge clk);
            before_reset = {state, req, done, timeout};
            start = 0;
            rst_n = 0;
            #1;
            check({state, req, done, timeout} === before_reset,
                  "Synchronous reset must not change outputs before a rising edge");
            @(posedge clk);
            #2;
            check({state, req, done, timeout} === 7'b0,
                  "Synchronous reset clears outputs at the next rising edge");
            cycle(0, 0, 0, 1);
        end
    endtask

    initial begin
        $dumpfile("f10_core_selfcheck.vcd");
        $dumpvars(0, clk, rst_n, start, ack, timeout_value, req, done, timeout, state,
                     model_phase, model_req, model_done, model_timeout, remaining);
        csv = $fopen("case_results.csv", "w");
        if (!csv) $fatal(1, "Cannot open case_results.csv");
        $fdisplay(csv, "case_id,description,start_ns,end_ns,cycles,checks,errors,result");

        begin_case("TC00_RESET", "Reset and idle hold");
        cycle(0, 0, 0, 0);
        cycle(0, 0, 0, 1);
        idle_clear();
        end_case();

        begin_case("TC01_NORMAL", "Normal complete four-phase handshake");
        complete_handshake(8, 0, 0);
        idle_clear();
        end_case();

        begin_case("TC02_DELAYED_SUCCESS", "Delayed ACK-high and ACK-low before deadline");
        complete_handshake(8, 3, 2);
        idle_clear();
        end_case();

        begin_case("TC03_NO_ACK", "No ACK-high timeout after four waiting cycles");
        cycle(1, 0, 4, 1);
        repeat (3) begin
            cycle(0, 0, 4, 1);
            check(timeout === 1'b0 && req === 1'b1, "No early request-phase timeout");
        end
        cycle(0, 0, 4, 1);
        check(timeout === 1'b1 && done === 1'b0, "Request-phase timeout on deadline");
        idle_clear();
        end_case();

        begin_case("TC04_ACK_STUCK", "ACK-high stuck timeout after four waiting cycles");
        cycle(1, 0, 4, 1);
        cycle(0, 1, 4, 1);
        cycle(0, 1, 4, 1);
        repeat (3) begin
            cycle(0, 1, 4, 1);
            check(timeout === 1'b0 && state === 4'd3, "No early return-phase timeout");
        end
        cycle(0, 1, 4, 1);
        check(timeout === 1'b1 && done === 1'b0, "Return-phase timeout on deadline");
        idle_clear();
        end_case();

        begin_case("TC05_BACK_TO_BACK", "Two complete transactions without an idle bubble");
        complete_handshake(2, 0, 0);
        complete_handshake(9, 3, 2);
        idle_clear();
        end_case();

        begin_case("TC06_STALE_ACK", "Reject start while stale ACK is high and do not queue it");
        repeat (3) begin
            cycle(1, 1, 3, 1);
            check(state === 4'd0 && req === 1'b0, "Start with stale ACK is rejected");
        end
        cycle(0, 0, 3, 1);
        check(state === 4'd0 && req === 1'b0, "Rejected start is not queued");
        complete_handshake(3, 0, 0);
        idle_clear();
        end_case();

        begin_case("TC07_BUSY_START", "Ignore start in all three busy states");
        cycle(1, 0, 5, 1);
        cycle(1, 0, 1, 1);
        cycle(1, 1, 255, 1);
        cycle(1, 1, 0, 1);
        cycle(1, 1, 1, 1);
        cycle(1, 0, 255, 1);
        check(done === 1'b1 && state === 4'd0, "Busy start must not interrupt completion");
        idle_clear();
        end_case();

        begin_case("TC08_LATCH_TIMEOUT", "Live timeout input changes do not reload either wait deadline");
        cycle(1, 0, 4, 1);
        cycle(1, 0, 0, 1);
        cycle(0, 0, 255, 1);
        cycle(1, 0, 1, 1);
        cycle(0, 0, 255, 1);
        check(timeout === 1'b1, "Request deadline keeps accepted N=4");
        idle_clear();
        cycle(1, 0, 4, 1);
        cycle(1, 1, 1, 1);
        cycle(1, 1, 0, 1);
        cycle(0, 1, 255, 1);
        cycle(1, 1, 1, 1);
        cycle(0, 1, 0, 1);
        cycle(1, 1, 255, 1);
        check(timeout === 1'b1, "Return deadline keeps accepted N=4");
        idle_clear();
        end_case();

        begin_case("TC09_SYNC_RESET", "Reset between edges in IDLE and all three busy states");
        for (phase = 0; phase < 4; phase = phase + 1) begin
            if (phase > 0) cycle(1, 0, 8, 1);
            if (phase > 1) cycle(0, 1, 8, 1);
            if (phase > 2) cycle(0, 1, 8, 1);
            check(state === phase[3:0], "Reset target phase reached");
            synchronous_reset_between_edges();
        end
        end_case();

        // Every value of the 8-bit configuration domain, both waiting phases,
        // both deadline outcomes. N=0 means one first waiting-edge decision.
        for (n = 0; n < 256; n = n + 1) begin
            begin_case($sformatf("SW_REQ_TIMEOUT_N%03d", n), "Request wait timeout at exact deadline");
            cycle(1, 0, n, 1);
            for (k = 1; k < ((n == 0) ? 1 : n); k = k + 1) cycle(0, 0, n, 1);
            cycle(0, 0, n, 1);
            check(timeout === 1'b1 && done === 1'b0, "Request sweep exact timeout");
            idle_clear();
            end_case();

            begin_case($sformatf("SW_LOW_TIMEOUT_N%03d", n), "Return wait timeout at exact deadline");
            cycle(1, 0, n, 1);
            cycle(0, 1, n, 1);
            cycle(0, 1, n, 1);
            for (k = 1; k < ((n == 0) ? 1 : n); k = k + 1) cycle(0, 1, n, 1);
            cycle(0, 1, n, 1);
            check(timeout === 1'b1 && done === 1'b0, "Return sweep exact timeout");
            idle_clear();
            end_case();

            begin_case($sformatf("SW_REQ_PRIORITY_N%03d", n), "ACK-high wins over timeout on exact deadline");
            cycle(1, 0, n, 1);
            for (k = 1; k < ((n == 0) ? 1 : n); k = k + 1) cycle(0, 0, n, 1);
            cycle(0, 1, n, 1);
            check(state === 4'd2 && timeout === 1'b0, "ACK-high priority on request deadline");
            cycle(0, 1, n, 1);
            cycle(0, 0, n, 1);
            check(done === 1'b1 && timeout === 1'b0, "Priority transaction completes all four phases");
            idle_clear();
            end_case();

            begin_case($sformatf("SW_LOW_PRIORITY_N%03d", n), "ACK-low wins over timeout on exact deadline");
            cycle(1, 0, n, 1);
            cycle(0, 1, n, 1);
            cycle(0, 1, n, 1);
            for (k = 1; k < ((n == 0) ? 1 : n); k = k + 1) cycle(0, 1, n, 1);
            cycle(0, 0, n, 1);
            check(done === 1'b1 && timeout === 1'b0, "ACK-low priority on return deadline");
            idle_clear();
            end_case();
        end

        begin_case("TC10_DETERMINISTIC_STRESS", "4096 synchronous input cycles seed F1002026 plus bounded drain");
        for (k = 0; k < 4096; k = k + 1) begin
            rng = {rng[30:0], rng[31] ^ rng[21] ^ rng[1] ^ rng[0]};
            if (rng[15:8] == 8'h00) random_resets = random_resets + 1;
            cycle(rng[0], rng[1], rng[23:16], rng[15:8] != 8'h00);
        end
        for (k = 0; k < 513 && model_phase != 0; k = k + 1) cycle(0, 0, 0, 1);
        idle_clear();
        check(model_phase == 0, "Stress drain leaves no transaction outstanding");
        end_case();

        check(cases == 1035, "All directed and sweep cases must execute");
        check(checks > 0, "A pass requires nonzero checks");
        check(failed_cases == 0, "No case may fail");
        $fdisplay(csv, "SUMMARY,all cases,0,%0d,%0d,%0d,%0d,%s", $time, cycles, checks, errors,
            (errors == 0 && failed_cases == 0) ? "PASS" : "FAIL");
        $fclose(csv);
        $display("SUMMARY cases=%0d failed_cases=%0d cycles=%0d checks=%0d errors=%0d seed=F1002026 stress_resets=%0d",
            cases, failed_cases, cycles, checks, errors, random_resets);
        if (errors != 0 || failed_cases != 0) $fatal(1, "F10 SELF-CHECK FAILED");
        $display("ALL TESTS PASSED: F10 core independent reference and deadline sweep");
        $finish;
    end

    initial begin
        #2000000;
        $fatal(1, "Global 2 ms simulation watchdog expired");
    end
endmodule
