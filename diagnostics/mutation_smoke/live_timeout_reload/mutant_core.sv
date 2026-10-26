module f10_handshake_controller #(
    parameter int START_INTERNAL = 0
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       ack,
    input  logic [7:0] timeout_value,
    output logic       req,
    output logic       done,
    output logic       timeout,
    output logic [3:0] state
);

    typedef enum logic [3:0] {
        S_IDLE         = 4'b0000,
        S_REQ_HIGH     = 4'b0001,
        S_ACK_HIGH     = 4'b0010,
        S_WAIT_ACK_LOW = 4'b0011
    } state_t;

    state_t state_q;
    logic [7:0] timeout_q;
    logic [7:0] count_q;

    assign state = state_q;
    assign req   = (state_q == S_REQ_HIGH) || (state_q == S_ACK_HIGH);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state_q   <= S_IDLE;
            timeout_q <= 8'd0;
            count_q   <= 8'd0;
            done      <= 1'b0;
            timeout   <= 1'b0;
        end else begin
            timeout_q <= timeout_value;
            done    <= 1'b0;
            timeout <= 1'b0;

            case (state_q)
                S_IDLE: begin
                    count_q <= 8'd0;
                    if (start) begin
                        timeout_q <= timeout_value;
                        count_q   <= 8'd0;
                        if (!ack)
                            state_q <= S_REQ_HIGH;
                        else
                            state_q <= S_IDLE;
                    end
                end

                S_REQ_HIGH: begin
                    if (ack) begin
                        count_q <= 8'd0;
                        state_q <= S_ACK_HIGH;
                    end else if (timeout_q == 8'd0) begin
                        timeout <= 1'b1;
                        state_q <= S_IDLE;
                    end else if (count_q == timeout_q - 8'd1) begin
                        timeout <= 1'b1;
                        state_q <= S_IDLE;
                    end else begin
                        count_q <= count_q + 8'd1;
                    end
                end

                S_ACK_HIGH: begin
                    count_q <= 8'd0;
                    state_q <= S_WAIT_ACK_LOW;
                end

                S_WAIT_ACK_LOW: begin
                    if (!ack) begin
                        done    <= 1'b1;
                        state_q <= S_IDLE;
                        count_q <= 8'd0;
                    end else if (timeout_q == 8'd0) begin
                        timeout <= 1'b1;
                        state_q <= S_IDLE;
                    end else if (count_q == timeout_q - 8'd1) begin
                        timeout <= 1'b1;
                        state_q <= S_IDLE;
                    end else begin
                        count_q <= count_q + 8'd1;
                    end
                end

                default: begin
                    state_q <= S_IDLE;
                    count_q <= 8'd0;
                    timeout_q <= timeout_value;
            done    <= 1'b0;
                    timeout <= 1'b0;
                end
            endcase
        end
    end

endmodule
