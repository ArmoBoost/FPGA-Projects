`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 08:32:50 PM
// Design Name: 
// Module Name: reverser_tb
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


module reverser_tb();
localparam N =3;

logic [2**N-1:0] org;
logic [2**N-1:0] rev;

reverser #(.N(N)) uut0(.*);

initial
begin
#40 $finish;
end

initial
begin
    org = 8'b11110000;
    #20;
    
    org = 8'b11001010;
    #20;
    
end

endmodule
