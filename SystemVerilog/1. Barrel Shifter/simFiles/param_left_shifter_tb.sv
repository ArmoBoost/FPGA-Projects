`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 06:15:04 PM
// Design Name: 
// Module Name: param_right_shifter_tb
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


module param_left_shifter_tb();
localparam N =2;

logic [(2**N)-1:0] a;
logic [N-1:0] amt;
logic [(2**N)-1:0] y;

param_left_shifter #(.N(N)) uut0(.*);

initial
begin
#40 $finish;
end

initial
begin
    /*a=8'b01010110;
    amt=3'b011;
    #10;
    
    a=8'b11110000;
    amt=3'b001;
    #10;
    
    a=8'b11111000;
    amt=3'b010;
    #10;
    
    a=8'b01110101;
    amt=3'b100;
    #10;*/
    
    a=4'b1001;
    amt = 2'b01;
    #10;
    
    a=4'b1100;
    amt = 2'b01;
    #10;
    
    
    a=4'b0011;
    amt = 2'b10;
    #10
    
    a=4'b0001;
    amt = 2'b11;
    #10;
    
    
end

endmodule
