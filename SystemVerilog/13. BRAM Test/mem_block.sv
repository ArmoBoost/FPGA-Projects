`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2022 07:29:58 PM
// Design Name: 
// Module Name: mem_block
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


/*module mem_block(
    input logic clk, 
    input logic we, //write enable
    input logic [11:0] addr,
    input logic [3:0] din,
    output logic [3:0] dout
    );
    
   logic [3:0] memory0 [0:1023];
   logic [3:0] memory1 [0:1023];
   logic [3:0] memory2 [0:1023];
   logic [3:0] memory3 [0:1023];
    
    always_ff @(posedge clk)
    begin
        if (we) begin
            if (addr <= 1023)
            begin 
                memory0[addr] <= din;
            end 
            else if (addr >= 1024 && addr < 2048) 
            begin
                memory1[addr - 1024] <= din;
            end 
            else if (addr >= 2048 && addr < 3072) 
            begin
                memory2[addr - 2048] <= din;
            end 
            else if (addr >= 3072) 
            begin
                memory3[addr - 3072] <= din;
            end
        end
        
        if (addr <= 1023) 
        begin 
            dout <= memory0[addr];
        end 
        
        else if (addr >= 1024 && addr < 2048) begin
            dout <= memory1[addr - 1024];
        end 
        
        else if (addr >= 2048 && addr < 3072) begin
            dout <= memory2[addr - 2048];
        end 
        else if (addr >= 3072) begin
            dout <= memory3[addr - 3072];
        end
    end
endmodule*/
//===========================================================================
module mem_block(
    input logic clk, 
    input logic we, //write enable
    input logic [11:0] addr,
    input logic [3:0] din,
    output logic [3:0] dout
    );
    
    logic weR0, weR1, weR2, weR3;
    logic [9:0]addr_RAM;
    logic [3:0] doutR0, doutR1, doutR2, doutR3;
    
    bram_synch_one_port bram0(
        .clk(clk),
        .we(weR0),
        .addr_a(addr_RAM),
        .din_a(din),
        .dout_a(doutR0)       
    );
    
    bram_synch_one_port bram1(
        .clk(clk),
        .we(weR1),
        .addr_a(addr_RAM),
        .din_a(din),
        .dout_a(doutR1)       
    );
    
    bram_synch_one_port bram2(
        .clk(clk),
        .we(weR2),
        .addr_a(addr_RAM),
        .din_a(din),
        .dout_a(doutR2)       
    );
    
    bram_synch_one_port bram3(
        .clk(clk),
        .we(weR3),
        .addr_a(addr_RAM),
        .din_a(din),
        .dout_a(doutR3)       
    );
    
    always_ff @(posedge clk)
    begin
        if (addr <=1023) 
        begin
            weR0 <= we;
            addr_RAM <= addr;
            dout <= doutR0;
        end 
        
        else if(addr >= 1024 && addr <2048)
        begin
            weR1 <= we;
            addr_RAM <= addr - 1024;
            dout <= doutR1;
        end 
        
        else if(addr >=2048 && addr< 3072)
        begin
            weR2 <= we;
            addr_RAM <= addr - 2048;
            dout <= doutR2;
        end 
        
        else if(addr>=3072)
        begin
            weR3 <= we;
            addr_RAM <= addr-3072;
            dout <= doutR3; 
        end 
    end
    
endmodule
    

