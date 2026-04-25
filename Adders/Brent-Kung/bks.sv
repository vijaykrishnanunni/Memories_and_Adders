`timescale 1ns/1ps

module brent_kung_adder #(
    parameter int N = 16
)(
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    input  logic         cin,
    output logic [N-1:0] sum,
    output logic         cout
);

    localparam int LEVELS = $clog2(N);
    localparam int STAGES = (2 * LEVELS) - 1;

    logic [STAGES:0][N-1:0] p;
    logic [STAGES:0][N-1:0] g;
    logic [N:0] carry;

    assign p[0] = a ^ b;
    assign g[0] = a & b;

    assign carry[0] = cin;

    genvar s, i;

    // Up-sweep / reduction tree
    generate
        for (s = 0; s < LEVELS; s = s + 1) begin : UPSWEEP
            for (i = 0; i < N; i = i + 1) begin : UP_NODE

                if (((i + 1) % (1 << (s + 1))) == 0) begin
                    assign g[s+1][i] = g[s][i] |
                                       (p[s][i] & g[s][i - (1 << s)]);

                    assign p[s+1][i] = p[s][i] &
                                       p[s][i - (1 << s)];
                end
                else begin
                    assign g[s+1][i] = g[s][i];
                    assign p[s+1][i] = p[s][i];
                end

            end
        end
    endgenerate


    // Down-sweep / distribution tree
    generate
        for (s = 0; s < LEVELS-1; s = s + 1) begin : DOWNSWEEP
            for (i = 0; i < N; i = i + 1) begin : DOWN_NODE

                localparam int SHIFT = (1 << (LEVELS - 2 - s));
                localparam int START = (3 * SHIFT) - 1;

                if ((i >= START) && (((i - START) % (2 * SHIFT)) == 0)) begin
                    assign g[LEVELS+s+1][i] =
                        g[LEVELS+s][i] |
                       (p[LEVELS+s][i] & g[LEVELS+s][i - SHIFT]);

                    assign p[LEVELS+s+1][i] =
                        p[LEVELS+s][i] &
                        p[LEVELS+s][i - SHIFT];
                end
                else begin
                    assign g[LEVELS+s+1][i] = g[LEVELS+s][i];
                    assign p[LEVELS+s+1][i] = p[LEVELS+s][i];
                end

            end
        end
    endgenerate


    // Generate final carries
    generate
        for (i = 0; i < N; i = i + 1) begin : CARRY_GEN
            assign carry[i+1] = g[STAGES][i] |
                               (p[STAGES][i] & cin);
        end
    endgenerate

    assign sum  = p[0] ^ carry[N-1:0];
    assign cout = carry[N];

endmodule
