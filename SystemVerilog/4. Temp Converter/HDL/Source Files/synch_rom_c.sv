`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 06:06:23 PM
// Design Name: 
// Module Name: synch_rom_c
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


module synch_rom_c
    (
    input logic clk,
    input logic [7:0] addr,
    
    output logic [7:0] data
    );
    
    // signal declaration
    // we are forcing it to be BRAM
    (*rom_style = "block"*) logic [7:0] rom [0:255];
    
    initial
        $readmemb("truth_table_c.mem", rom);
        
    always_ff @(posedge clk)
        data <= rom[addr];
        
endmodule
