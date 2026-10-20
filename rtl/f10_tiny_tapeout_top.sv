`default_nettype none

// Working integration assumption: uio_in[1] is START (option 2 in the
// supplied functional_spec). The charter does not explicitly assign START.
// ena suppresses NEW starts only; an accepted handshake must keep progressing.
module f10_tiny_tapeout_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    wire req, done, timeout;
    wire [3:0] state;

    f10_handshake_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(ena && uio_in[1]),
        .ack(uio_in[0]),
        .timeout_value(ui_in),
        .req(req),
        .done(done),
        .timeout(timeout),
        .state(state)
    );

    assign uo_out  = {1'b0, state, timeout, done, req};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    wire _unused = &{uio_in[7:2], 1'b0};
endmodule

`default_nettype wire
