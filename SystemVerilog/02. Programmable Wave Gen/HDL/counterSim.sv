`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 05:59:00 PM
// Design Name: 
// Module Name: counterSim
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


module mod_m_counter_tb();



logic clk, reset, max_tick;
logic [3:0] M, q;

// instantiate uut
mod_m_counter uut0(.*);

// test vectors

// clock (period = 20 ns)
always
begin
    clk = 1'b0;
    #1;
    clk = 1'b1;
    #1;
end

// initial reset
initial
begin
    M = 3;
    reset = 1'b1;
    @(negedge clk)
    reset = 1'b0;
end
// monitor 
endmodule