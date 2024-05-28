`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2020 10:45:01 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file
    (
        input logic clk,
        input logic w_en,
        input logic [2: 0] r_addr, // reading address
        input logic [2: 0] w_addr, // writing address
        
        input logic  [15: 0] w_data,                      // 16-bit     
        output logic [7: 0] r_data                        // 8-bit
    );
    
    // signal declaration
    //    width        depth
    logic [7:0] memory [0:7];
    
    // write operation
    always_ff @(posedge clk)
    begin
        if (w_en)
        begin
            memory[w_addr]     <= w_data[7:0];
            memory[w_addr + 1] <= w_data[15:8];
        end
    end
            
    // read operation
    assign r_data = memory[r_addr];
endmodule
