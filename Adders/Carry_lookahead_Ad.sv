`timescale 1ns/1ps

module nbit_cla #(
    parameter N = 16
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);

    wire [N-1:0] p, g;
    wire [N:0]   c;

    assign c[0] = cin;

    assign p = a ^ b;
    assign g = a & b;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : CLA_STAGE
            assign c[i+1] = g[i] | (p[i] & c[i]);
            assign sum[i] = p[i] ^ c[i];
        end
    endgenerate

    assign cout = c[N];

endmodule
