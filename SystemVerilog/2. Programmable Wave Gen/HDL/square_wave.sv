`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2024 05:53:01 PM
// Design Name: 
// Module Name: square_wave
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


module square_wave(
    input logic clk,reset,
    input logic [3:0] up,
    input logic [3:0] down,
    output logic sq_wave
    );
    
    logic [3:0] ud_sel; //up or down signal for the mux
    logic r_next, r_reg;
    
    //counter
     mod_m_counter counter(
        .clk(clk),
        .reset(reset),
        .M(ud_sel),
        .max_tick(r_next)
     );
     
   //T FF
    always_ff@(posedge clk, posedge reset)
    begin
        if(reset)
            begin
            r_reg<=0;
            end
        else
            if(r_next)
                r_reg <= ~r_reg;
            else
                r_reg <= r_reg;
    end
    
    //mux
    always_comb
    begin
        if(reset)//don't think this is needed...
            ud_sel=4'b0000;
        else if(r_reg)
            ud_sel=up;
        else
            ud_sel=down;     
    end
    
    assign sq_wave = r_reg;
endmodule