`timescale 1ns/1ps

module kogge_stone_16bit (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,
    output wire [15:0] sum,
    output wire        cout
);

    wire [15:0] p0, g0;
    wire [15:0] p1, g1;
    wire [15:0] p2, g2;
    wire [15:0] p3, g3;
    wire [15:0] p4, g4;
    wire [16:0] c;

    assign p0 = a ^ b;
    assign g0 = a & b;

    assign c[0] = cin;

    // Include cin in bit 0 generate
    assign g1[0] = g0[0] | (p0[0] & cin);
    assign p1[0] = p0[0];

    genvar i;

    // Stage 1: distance 1
    generate
        for (i = 1; i < 16; i = i + 1) begin : STAGE1
            assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
            assign p1[i] = p0[i] & p0[i-1];
        end
    endgenerate

    // Stage 2: distance 2
    generate
        for (i = 0; i < 2; i = i + 1) begin : STAGE2_PASS
            assign g2[i] = g1[i];
            assign p2[i] = p1[i];
        end

        for (i = 2; i < 16; i = i + 1) begin : STAGE2
            assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
            assign p2[i] = p1[i] & p1[i-2];
        end
    endgenerate

    // Stage 3: distance 4
    generate
        for (i = 0; i < 4; i = i + 1) begin : STAGE3_PASS
            assign g3[i] = g2[i];
            assign p3[i] = p2[i];
        end

        for (i = 4; i < 16; i = i + 1) begin : STAGE3
            assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
            assign p3[i] = p2[i] & p2[i-4];
        end
    endgenerate

    // Stage 4: distance 8
    generate
        for (i = 0; i < 8; i = i + 1) begin : STAGE4_PASS
            assign g4[i] = g3[i];
            assign p4[i] = p3[i];
        end

        for (i = 8; i < 16; i = i + 1) begin : STAGE4
            assign g4[i] = g3[i] | (p3[i] & g3[i-8]);
            assign p4[i] = p3[i] & p3[i-8];
        end
    endgenerate

    assign c[16:1] = g4;
    assign sum = p0 ^ c[15:0];
    assign cout = c[16];

endmodule
