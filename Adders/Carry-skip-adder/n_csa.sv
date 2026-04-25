`timescale 1ns/1ps

module nbit_carry_skip #(
    parameter N = 16,
    parameter BLOCK_SIZE = 4
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);

    localparam NUM_BLOCKS = N / BLOCK_SIZE;

    wire [NUM_BLOCKS:0] block_carry;
    assign block_carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : SKIP_BLOCKS

            carry_skip_block #(.WIDTH(BLOCK_SIZE)) BLOCK (
                .a    (a[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
                .b    (b[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
                .cin  (block_carry[i]),
                .sum  (sum[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
                .cout (block_carry[i+1])
            );

        end
    endgenerate

    assign cout = block_carry[NUM_BLOCKS];

endmodule


module carry_skip_block #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    wire [WIDTH-1:0] p;
    wire [WIDTH:0]   c;
    wire             block_propagate;

    assign c[0] = cin;
    assign p = a ^ b;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : RCA_INSIDE_BLOCK
            assign sum[i] = p[i] ^ c[i];
            assign c[i+1] = (a[i] & b[i]) | (p[i] & c[i]);
        end
    endgenerate

    assign block_propagate = &p;

    assign cout = block_propagate ? cin : c[WIDTH];

endmodule
