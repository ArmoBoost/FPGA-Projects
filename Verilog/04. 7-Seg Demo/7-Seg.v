`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2023 01:31:26 PM
// Design Name: 
// Module Name: lab6
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


module lab6(sysCLK,Cx,AN);
    input sysCLK;
    output [7:0] Cx;
    output [7:0] AN;
    wire [7:0] C1;
    wire [7:0] C2;
    wire [7:0] C3;
    wire [7:0] C4;
    wire fourHundo;
    wire zeroFive;
    wire [1:0] sel;
    slowerClkGen s0(sysCLK,125_000,fourHundo);
    slowerClkGen s1 (sysCLK,100_000_000,zeroFive);
    upcounter u0 (fourHundo,1,sel);
    pattGen p0 (zeroFive,C1,C2,C3,C4);
    mux4to1 m0 (C1,C2,C3,C4,sel,Cx,AN);
endmodule

module pattGen(clk,C1,C2,C3,C4);
input clk;
output reg[7:0]C1;
output reg[7:0]C2;
output reg[7:0]C3;
output reg[7:0]C4;

always@(posedge clk)

begin
C1<=C1+1;
C2<=C2+2;
C3<=C3+3;
C4<=C4+4;
end
endmodule

module mux4to1 (w0, w1, w2, w3, S, f,AN);

  input [7:0] w0, w1, w2, w3;
  output reg [7:0] AN;
  input [2:0] S;  
  output reg [7:0] f;

  always @(*)
  begin

  if (S == 2'b00)
    begin
    f = w0;
    AN=8'b11110111;
    end

  else if (S == 2'b01)
    begin
    f = w1;
    AN=8'b11111110;
    end

  else if (S == 2'b10)
    begin
    f = w2;
    AN=8'b11111101;
    end

  else if (S == 2'b11)
    begin
    f = w3;
    AN=8'b11111011;
    end
 end
endmodule

module upcounter (Clock, E, Q);
    input Clock, E;
    output reg [1:0] Q;
    always @(posedge Clock)
     if (E)
     Q <= Q + 1;
endmodule

module slowerClkGen(clk, HZ, outsignal);
    input clk;
    input [26:0] HZ;
    output  outsignal;
    reg [26:0] counter;  
    reg outsignal;
    always @ (posedge clk)
    begin
    counter = counter +1;
    if (counter == HZ) //why is this a 1 Hz? 50_000_000
    begin
    outsignal=~outsignal;
    counter =0;
    end
   end
endmodule



