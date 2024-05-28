`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 07:01:04 PM
// Design Name: 
// Module Name: param_left_shifter
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


module param_left_shifter #(parameter N = 4) (
    input logic [(2**N)-1:0] a,
    input logic [N-1:0] amt,
    output logic [(2**N)-1:0] y
);
    integer i;

    always_comb begin
        y = a; 
        for (i = 0; i < amt; i = i + 1) begin
            y = {y[(2**N)-2:0],y[(2**N)-1]};  //gets second msb - lsb and puts them at the front and gets the msb and puts it in the back. Repeat until i > amt
        end
    end
endmodule
