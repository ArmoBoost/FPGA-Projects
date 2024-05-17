`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2024 01:16:42 PM
// Design Name: 
// Module Name: early_debouncer_tb
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


module early_debouncer_tb();


// ----- [1] Signal declration
//localparam N = 8;

logic clk;
logic reset;
logic sw;
logic db;


// ----- [2] instantiate unit under test (uut)
//universal_shift_register #(.N(N)) uut0(.*);
early_debouncer uut0 (
    .clk(clk),
    .reset(reset),
    .sw(sw),
    .db(db)   
    );



// ----- [3] test vectors 
initial 
begin
    sw = 0;
    #400;

    sw = 1;          // debouncing 
    #40;  
    sw = 0;
    #90;
    sw = 1;
    #90;
    sw = 0;
    #90;
    sw = 1;
    #5000;  
    
    sw = 0;
    #40;  
    sw = 1;
    #90;
    sw = 0;
    #90;
    sw = 1;
    #50;
    $finish;
end


// clock generator (20 ns clock)
always
begin
    clk = 1'b1;
    #10;
    clk = 1'b0;
    #10;
end

//initial reset
initial
begin
    reset = 1'b1;
    @(negedge clk)
    reset = 1'b0;
end


// ----- [4] monitor






endmodule

