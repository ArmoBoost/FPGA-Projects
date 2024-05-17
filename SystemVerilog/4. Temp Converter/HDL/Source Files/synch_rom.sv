`timescale 1ns / 1ps









module synch_rom_f
    (
    input logic clk,
    input logic [7:0] addr,
    
    output logic [7:0] data
    );
    
    // signal declaration
    // we are forcing it to be BRAM
    (*rom_style = "block"*) logic [7:0] rom [0:255];
    
    initial
        $readmemb("truth_table_f.mem", rom);
        
    always_ff @(posedge clk)
        data <= rom[addr];
endmodule
