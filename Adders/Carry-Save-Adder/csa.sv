`timescale 1ns/1ps

// 4-bit Carry Save Adder block
module csa_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [3:0] c,
    output wire [3:0] sum,
    output wire [4:0] carry
);

    assign sum = a ^ b ^ c;

    assign carry[0]   = 1'b0;
    assign carry[4:1] = (a & b) | (b & c) | (a & c);

endmodule


// 16-bit CSA using four 4-bit CSA blocks
module csa_16bit_using_4bit_blocks (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [15:0] c,
    output wire [15:0] sum,
    output wire [16:0] carry
);

    wire [4:0] carry0, carry1, carry2, carry3;

    csa_4bit CSA0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .c(c[3:0]),
        .sum(sum[3:0]),
        .carry(carry0)
    );

    csa_4bit CSA1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .c(c[7:4]),
        .sum(sum[7:4]),
        .carry(carry1)
    );

    csa_4bit CSA2 (
        .a(a[11:8]),
        .b(b[11:8]),
        .c(c[11:8]),
        .sum(sum[11:8]),
        .carry(carry2)
    );

    csa_4bit CSA3 (
        .a(a[15:12]),
        .b(b[15:12]),
        .c(c[15:12]),
        .sum(sum[15:12]),
        .carry(carry3)
    );

    // Combine shifted carry outputs
    assign carry[0]    = carry0[0];
    assign carry[4:1]  = carry0[4:1];
    assign carry[8:5]  = carry1[4:1];
    assign carry[12:9] = carry2[4:1];
    assign carry[16:13]= carry3[4:1];

endmodule
