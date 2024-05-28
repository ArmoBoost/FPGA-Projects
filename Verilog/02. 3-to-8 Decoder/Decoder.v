`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2023 01:39:02 PM
// Design Name: 
// Module Name: lab4
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

module lab4(AN,data,Cx);
    input [2:0] data;
    output [7:0]Cx;
    wire [7:0] y;
    output [7:0] AN;
    assign AN=8'b01111111;
    decoder d0 (data, y);
    seg_seven seg0 (y,Cx);
endmodule

module seg_seven(y,Cx);
    input [7:0]y;
    output reg [7:0]Cx;
    
    always@*
    case(y)
        1:Cx=8'b11000000;
        2:Cx=8'b11111001;
        4:Cx=8'b10100100;
        8:Cx=8'b10110000;
        16:Cx=8'b10011001;
        32:Cx=8'b10010010;
        64:Cx=8'b10000010;
        128:Cx=8'b11111000;
        
        default: Cx=8'b00000000;
     endcase
    
endmodule

module decoder(data,y);
    input [2:0]data;
    output reg [7:0] y;
    
    always @(data)
        begin
            y=0;
            y[data]=1;
        end
endmodule

