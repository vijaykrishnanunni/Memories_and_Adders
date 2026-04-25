`timescale 1ns/1ps

module csla_16bit (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,
    output wire [15:0] sum,
    output wire        cout
);

    wire c4, c8, c12;

    // 4-bit RCA for first block
    ripple_adder #(.WIDTH(4)) RCA0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(cin),
        .sum(sum[3:0]),
        .cout(c4)
    );

    // 4-bit CSLA block
    csla_block #(.WIDTH(4)) CSLA1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(c4),
        .sum(sum[7:4]),
        .cout(c8)
    );

    // 4-bit CSLA block
    csla_block #(.WIDTH(4)) CSLA2 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(c8),
        .sum(sum[11:8]),
        .cout(c12)
    );

    // 4-bit CSLA block
    csla_block #(.WIDTH(4)) CSLA3 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(c12),
        .sum(sum[15:12]),
        .cout(cout)
    );

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
        .a(a), .b(b), .cin(1'b0),
        .sum(sum0), .cout(cout0)
    );

    ripple_adder #(.WIDTH(WIDTH)) RCA1 (
        .a(a), .b(b), .cin(1'b1),
        .sum(sum1), .cout(cout1)
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
