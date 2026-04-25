`timescale 1ns/1ps

module sqrt_csla_16bit (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,
    output wire [15:0] sum,
    output wire        cout
);

    wire c4, c7, c11;

    // Square-root CSLA block sizes: 4, 3, 4, 5

    ripple_adder #(.WIDTH(4)) RCA0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(cin),
        .sum(sum[3:0]),
        .cout(c4)
    );

    csla_block #(.WIDTH(3)) CSLA1 (
        .a(a[6:4]),
        .b(b[6:4]),
        .cin(c4),
        .sum(sum[6:4]),
        .cout(c7)
    );

    csla_block #(.WIDTH(4)) CSLA2 (
        .a(a[10:7]),
        .b(b[10:7]),
        .cin(c7),
        .sum(sum[10:7]),
        .cout(c11)
    );

    csla_block #(.WIDTH(5)) CSLA3 (
        .a(a[15:11]),
        .b(b[15:11]),
        .cin(c11),
        .sum(sum[15:11]),
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
