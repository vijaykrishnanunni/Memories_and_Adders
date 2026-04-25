`timescale 1ns/1ps

module nbit_csla #(
    parameter N = 16,
    parameter BLOCK_SIZE = 4
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);

    localparam NUM_BLOCKS = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;

    wire [NUM_BLOCKS:0] carry;
    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : CSLA_BLOCKS

            localparam START = i * BLOCK_SIZE;
            localparam WIDTH = (START + BLOCK_SIZE <= N) ?
                               BLOCK_SIZE : (N - START);

            csla_block #(.WIDTH(WIDTH)) BLOCK (
                .a    (a[START + WIDTH - 1 : START]),
                .b    (b[START + WIDTH - 1 : START]),
                .cin  (carry[i]),
                .sum  (sum[START + WIDTH - 1 : START]),
                .cout (carry[i+1])
            );

        end
    endgenerate

    assign cout = carry[NUM_BLOCKS];

endmodule


module csla_block #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    wire [WIDTH-1:0] sum0, sum1;
    wire cout0, cout1;

    ripple_adder #(.WIDTH(WIDTH)) RCA0 (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum0),
        .cout(cout0)
    );

    ripple_adder #(.WIDTH(WIDTH)) RCA1 (
        .a(a),
        .b(b),
        .cin(1'b1),
        .sum(sum1),
        .cout(cout1)
    );

    assign sum  = cin ? sum1  : sum0;
    assign cout = cin ? cout1 : cout0;

endmodule


module ripple_adder #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    wire [WIDTH:0] carry;
    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : RCA_STAGE
            assign sum[i] = a[i] ^ b[i] ^ carry[i];
            assign carry[i+1] = (a[i] & b[i]) |
                                (a[i] & carry[i]) |
                                (b[i] & carry[i]);
        end
    endgenerate

    assign cout = carry[WIDTH];

endmodule
