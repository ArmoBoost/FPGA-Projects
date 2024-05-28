`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2023 01:43:06 PM
// Design Name: 
// Module Name: lab5
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


module lab5(reset,sysCLK,Cx,AN);
    input reset;
    input sysCLK;
    output [7:0] Cx;
    output [7:0] AN;
    wire outsig;
    wire [2:0] data;
    assign AN=8'b01111111;
    slowerClkGen s0(sysCLK, reset,outsig);
    upcounter u0 (outsig,1,data);
    lab4 l0 (data,Cx);
    
endmodule

module upcounter (Clock, E, Q);
    input Clock, E;
    output reg [2:0] Q;
always @(posedge Clock)
    if (E)
    Q <= Q + 1;
endmodule

module slowerClkGen(clk, resetSW, outsignal);
    input clk;
    input resetSW;
    output  outsignal;
    reg [26:0] counter;  
    reg outsignal;
    always @ (posedge clk)
    begin
if (resetSW)
  begin
counter=0;
outsignal=0;
  end
else
  begin
  counter = counter +1;
  if (counter == 50_000_000) //why is this a 0.5 Hz?
begin
outsignal=~outsignal;
counter =0;
end
 end
   end
endmodule

module lab4(data,Cx);
    input [2:0] data;
    output [7:0]Cx;
    wire [7:0] y;
    decoder d0 (data, y);
    seg_seven seg0 (y,Cx);
endmodule

module seg_seven(y,Cx);
    input [7:0]y;
    output reg [7:0]Cx;
    
    always@*
    case(y)
        1:Cx=8'b11000000;
        2:Cx=8'b11111001;
        4:Cx=8'b10100100;
        8:Cx=8'b10110000;
        16:Cx=8'b10011001;
        32:Cx=8'b10010010;
        64:Cx=8'b10000010;
        128:Cx=8'b11111000;
        
        default: Cx=8'b00000000;
     endcase
    
endmodule

module decoder(data,y);
    input [2:0]data;
    output reg [7:0] y;
    
    always @(data)
        begin
            y=0;
            y[data]=1;
        end
endmodule


