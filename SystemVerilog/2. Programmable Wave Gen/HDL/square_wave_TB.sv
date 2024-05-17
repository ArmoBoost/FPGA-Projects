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


module square_wave_TB();



logic clk, reset, sq_wave;
logic [3:0] up,down;

// instantiate uut
square_wave uut0(.*);

// test vectors

// clock (period = 10 ns)
always
begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

// initial reset
initial
begin
    reset = 1'b1;
    @(negedge clk);
    reset = 1'b0;
    
    up=4'b0001; 
    down = 4'b0001;
    
    #500;
    up=4'b0010;
    down=4'b1000;
    
    #2500;
    up=4'b1100;
    down=4'b1111;
end
// monitor 
endmodule