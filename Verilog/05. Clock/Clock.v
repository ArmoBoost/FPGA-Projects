`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2023 01:11:53 PM
// Design Name: 
// Module Name: lab7
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


module lab7(sysCLK,Cx,AN);
    input sysCLK;
    output [7:0] Cx;
    output [7:0] AN;
    //assign AN = 11111110;
    wire one;
    wire [3:0] a0,a1,a2,a3;
    wire fourHundo;
    wire [10:0]count;
    wire [2:0] muxCount;
    slowerClkGen s0(sysCLK,125_000,fourHundo);
    slowerClkGen s1 (sysCLK,50_000_000,one);
    upcounter u1 (fourHundo,1,muxCount);
    upcounter2 u0 (one,1,count);
    secMin sM0 (one,count,a0,a1,a2,a3);
    mux4to1 (a0,a1,a2,a3,muxCount,Cx,AN);
    //seg_seven(count,Cx);
endmodule

//module lab6(sysCLK,Cx,AN);
//    input sysCLK;
//    output [7:0] Cx;
//    output [7:0] AN;
//    assign AN = 11111110;
//   // wire [7:0] C1;
//    wire [3:0] Sec;
////    wire [7:0] C2;
////    wire [7:0] C3;
////    wire [7:0] C4;
//    wire fourHundo;
//    wire one;
//    wire [1:0] sel;
    
//    upcounter u0 (fourHundo,1,sel);
//    secMin(one,Sec);
//    pattGen p0 (Sec,Cx);
//    //mux4to1 m0 (C1,C2,C3,C4,sel,Cx,AN);
//endmodule

//module pattGen(Sec,C1/*,C2,C3,C4*/);
////input [5:0] Min;
//input [3:0] Sec;
//output [7:0]C1;
//seg_seven s0(sec,C1);
////output reg[7:0]C2;
////output reg[7:0]C3;
////output reg[7:0]C4; 

//endmodule

module secMin(clk,count,a0,a1,a2,a3);
input [10:0] count;
input clk;
output reg [3:0] a0;
output reg [3:0] a1;
output reg [3:0] a2;
output reg [3:0] a3;
integer x = 0;
integer y=0;





always@(posedge clk)
    begin
    a0=count%10;
    a1=count/10;
    if(a1==0&&a0==0)
        x=x+1;
    a2=x;
    
    if(a2==9&&a1==5&&a0==9)
        begin
        a2=0;
        x=0;
        y=y+1;
        end
      a3=y;
    end
endmodule


module mux4to1 (w0, w1,w2,w3, S, f,AN);

  input [3:0] w0, w1,w2,w3;
  output reg [7:0] AN;
  input [2:0] S;  
  output reg [7:0] f;
  wire [7:0] ww0,ww1,ww2,ww3;
  seg_seven ss0 (w0,ww0);
  seg_seven ss1 (w1,ww1);
  seg_seven ss2 (w2,ww2);
  seg_seven ss3 (w3,ww3);


  always @(*)
  begin
    
  if (S == 2'b00)
    begin
    f=ww0;
    AN=8'b11111110;
    end

  else if (S == 2'b01)
    begin
    f=ww1;
    AN=8'b11111101;
    end

  else if (S == 2'b10)
    begin
    f = ww2;
    AN=8'b11111011;
    end

  else if (S == 2'b11)
    begin
    f = ww3;
    AN=8'b11110111;
    end
 end
endmodule

module upcounter (Clock, E, Q);
    input Clock, E;
    output reg [2:0] Q;
    always @(posedge Clock)
     if (E)
     Q <= Q + 1;
endmodule

module upcounter2 (Clock, E, Q);
    input Clock, E;
    output reg [10:0] Q;
    initial Q = 1;

    always @(posedge Clock)
     if (E)
        begin
            Q <= Q + 1;
            if(Q==59)
                Q<=0;
        end
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

module seg_seven(y,Cx);
    input [3:0]y;
    output reg [7:0]Cx;
    
    always@*
    case(y)
        0:Cx=8'b11000000;
        1:Cx=8'b11111001;
        2:Cx=8'b10100100;
        3:Cx=8'b10110000;
        4:Cx=8'b10011001;
        5:Cx=8'b10010010;
        6:Cx=8'b10000010;
        7:Cx=8'b11111000;
        8:Cx=8'b10000000;
        9:Cx=8'b10011000;
        
        default: Cx=8'b00000000;
     endcase
    
endmodule



