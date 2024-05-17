`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 05:54:20 PM
// Design Name: 
// Module Name: counter
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

module mod_m_counter
    (
        input logic clk, reset,
        input logic [3:0] M,
        //output logic [3:0] q,
        output logic max_tick
    );
    
    // signal declaration
    logic [10:0] r_next, r_reg;
    
    // body
    // [1] Register segment
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end
    
    // [2] next-state logic segment
    assign r_next = (r_reg == ((M*10) - 1))? 0: r_reg + 1;
    
    // [3] output logic segment
    //assign q = r_reg;    
    
    assign max_tick = (r_reg == (M*10) - 1) ? 1'b1: 1'b0;
    
endmodule

 