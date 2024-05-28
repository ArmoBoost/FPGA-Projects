`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2024 10:29:00 PM
// Design Name: 
// Module Name: PmodENC
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


module PmodENC(
    input  logic clk,
    input  logic reset,

    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,

    // external port  
    input logic [3:0] JA
    );
    
	// Internal wires 
	logic [3:0] rd_data_reg;                        // -------------------- register to hold the data 
	
	logic A =        JA[0];
	logic B =        JA[1];
	logic pmod_btn = JA[2];
	logic pmod_SW =  JA[3];
	
	logic db_A, db_B;                            // The debounced values
	logic enc_A, enc_B;                          // The final encoded values to (after making sure it is right or left)
	logic A_tick, B_tick;                        // The edges of the final values
	//logic enc_A_flag, enc_B_flag;
	logic [1:0] LED;
	logic de_LED0, de_LED1;
	
	// ------------------------------------------ Resgister Update
	always_ff @(posedge clk, posedge reset)
      if (reset)
         rd_data_reg <= 0;
      else   
         rd_data_reg <= {pmod_SW, pmod_btn, de_LED1, db_LED0};
	
	
	
	// -------------------------------------------- Next Level Logic
	// Instantiate Modules
	// ------------------------ filter debouncing 
	Debouncer db
	(
	   .clk(clk), 
	   .Ain(A), 
	   .Bin(B), 
	   
	   .Aout(db_A), 
	   .Bout(db_B)
	);
 	
 	// ------------------------ Encoder module 
 	Encoder enc 
 	(
 	  .clk(clk), 
 	  .A(db_A), 
 	  .B(db_B), 
 	  .BTN(pmod_btn), 
 	  
 	  .EncOut(),                   // not used
 	  .LED(LED),                    
 	  .encoded_A(enc_A),
      .encoded_B(enc_B)
 	);
 	
 	Debouncer db2
	(
	   .clk(clk), 
	   .Ain(LED[0]), 
	   .Bin(LED[1]), 
	   
	   .Aout(db_LED0), 
	   .Bout(de_LED1)
	);
 	
 	
 	
 	
 	
   
 	
 
 
 
   // --------- slot read interface
   assign rd_data[3:0] = rd_data_reg;
   assign rd_data[31:4] = 0;
 	
 	
 	
endmodule
