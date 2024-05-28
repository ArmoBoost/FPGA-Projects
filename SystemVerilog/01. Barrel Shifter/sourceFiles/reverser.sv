`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 08:25:44 PM
// Design Name: 
// Module Name: multi_barrel_shifter_reverser
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reverser #
(parameter N = 3) 
(
    input logic [2**N-1:0] org,
    output logic [2**N-1:0] rev
);

    genvar i;
    generate
        for (i = 0; i < 2**N; i++)
            begin 
            assign rev[i] = org[2**N-1-i]; //goes in order putting msb to lsb until i> 2^N
            end
    endgenerate

endmodule

