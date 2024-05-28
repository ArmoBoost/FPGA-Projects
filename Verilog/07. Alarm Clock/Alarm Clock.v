`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2023 03:40:33 PM
// Design Name: 
// Module Name: Lab9
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


module lab7(sysCLK,hourBut,minBut,status,alarmOnOff,Cx,AN,audioOut,aud_sd);
    input sysCLK;
    input hourBut;
    input minBut;
    input alarmOnOff;
    output [7:0] Cx;
    output [7:0] AN;
    output reg [15:0]status;
    output audioOut;
    output aud_sd;
    assign aud_sd = 1'b1;
    reg onOrOff;
    wire one;
    wire [3:0] a0,a1,a2,a3;
    wire fourHundo;
    wire music;
    wire [10:0]count;
    //wire [2:0] muxCount;
    wire [3:0] alarmCount;
    wire alarmSound;
    always@*
    begin
        if(alarmOnOff)
        status=15'b111111111111111;
        else
        status=0;
        
    end
    slowerClkGen s0(sysCLK,125_000,fourHundo);
    slowerClkGen s1 (sysCLK,50_000_000,one);
    slowerClkGen s2 (sysCLK,100_000_000,music);
    upcounter u2(fourHundo,1,alarmCount);
    upcounter u1 (fourHundo,1,muxCount);
    upcounter2 u0 (one,1,count);
    secMin sM0 (one,count,a0,a1,a2,a3);
    alarm (a0,a1,a2,a3,alarmOnOff,minBut,hourBut,alarmCount,AN,Cx,one,alarmSound);
    SongPlayer sp(sysCLK, alarmSound,audioOut,aud_sd);
endmodule

module secMin(clk,count,a0,a1,a2,a3);
input [10:0] count;
input clk;
output reg [3:0] a0;
output reg [3:0] a1;
output reg [3:0] a2;
output reg [3:0] a3;
integer x = 0;
integer y=0;
integer z=0;

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
        z=1;
        end
     if(z==1)
     begin
     y=y+1;
     a3=y;
     end
      
    end
endmodule

module alarm (w0, w1,w2,w3,onOff,minBut,hourBut,S,AN,Cx,clk,alarmSound);
    input onOff;
    input clk;
    input [3:0] w0, w1,w2,w3;
    wire [7:0] ww0,ww1,ww2,ww3;
    integer min=0;
    integer hour=0;
    integer x=0;
    input minBut;
    input hourBut;
    input [3:0] S;
    wire [7:0] xx0,xx1,xx2,xx3;
    integer x0,x1,x2,x3;
    output reg [7:0]Cx;
    output reg [7:0] AN;
    output reg alarmSound;
    
    always@(posedge clk)
    begin
    if(minBut)
        begin
        min=min+1;
            if(min==60)
            min=0;
        x0=min%10;
        x1=min/10;
        end
     if(hourBut)
        begin
        hour=hour+1;
            if(hour==24)
            hour=0;
        x2=hour%10;
        x3=hour/10;
    end
    end
    
    seg_seven a1 (x0,xx0);
    seg_seven a2 (x1,xx1);
    seg_seven a3 (x2,xx2);
    seg_seven a4 (x3,xx3);
    seg_seven ss0 (w0,ww0);
    seg_seven ss1 (w1,ww1);
    seg_seven ss2 (w2,ww2);
    seg_seven ss3 (w3,ww3);
    
    always@*
        begin
        
        if (S == 3'b000)
        begin
        Cx=xx3;
        AN=8'b01111111;
        end
    
        else if (S == 3'b001)
        begin
        Cx=xx2;
        AN=8'b10111111;
        end
    
      else if (S == 3'b010)
        begin
        Cx = xx1;
        AN=8'b11011111;
        end
    
      else if (S == 3'b011)
        begin
        Cx = xx0;
        AN=8'b11101111;
        end
        
        ////////////
   else if (S == 3'b100)
    begin
    Cx=ww0;
    AN=8'b11111110;
    end

  else if (S == 3'b101)
    begin
    Cx=ww1;
    AN=8'b11111101;
    end

  else if (S == 3'b110)
    begin
    Cx = ww2;
    AN=8'b11111011;
    end

  else if (S == 3'b111)
    begin
    Cx = ww3;
    AN=8'b11110111;
    end
    
    if(ww0==xx0&&ww1==xx1&&ww2==xx2&&ww3==xx3&&onOff)
    begin
        AN=8'b00000000;
        Cx=8'b10011000;
        alarmSound=1;
        x=1;
        end
        
    else if(x==0)
    begin
        alarmSound=0;
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



module MusicSheet( input [9:0] number, 
output reg [19:0] note,//what is the max frequency  
output reg [4:0] duration);
parameter   QUARTER = 5'b00010; 
parameter HALF = 5'b00100;
parameter ONE = 2* HALF;
parameter TWO = 2* ONE;
parameter FOUR = 2* TWO;
parameter A=113_636,As=107_259, C4=95_556, D4=85_131,Ds=80_353, E4 = 75_843, F4=71_586,
 G4 = 63_776, Gs=60_196,C5 = 47_778, SP = 1;  
 
always @ (number) begin
case(number) //aerials
0: begin note = Ds; duration = HALF; end 
1: begin note = SP; duration = HALF; end 
2: begin note = D4; duration = HALF; end 
3: begin note = SP; duration = HALF; end 
4: begin note = C4; duration = HALF; end 
5: begin note = SP; duration = HALF; end 
6: begin note = C4; duration = HALF; end 
7: begin note = SP; duration = HALF; end 
8: begin note = C4; duration = ONE; end 
9: begin note = SP; duration = HALF; end 

10: begin note = F4; duration = HALF; end 
11: begin note = SP; duration = HALF; end 
12: begin note = Ds; duration = HALF; end 
13: begin note = SP; duration = HALF; end 
14: begin note = D4; duration = HALF; end 
15: begin note = SP; duration = HALF; end 
16: begin note = D4; duration = HALF; end 
17: begin note = SP; duration = HALF; end 
18: begin note = D4; duration = ONE; end 
19: begin note = SP; duration = HALF; end 

20: begin note = Ds; duration = HALF; end 
21: begin note = SP; duration = HALF; end 
22: begin note = F4; duration = HALF; end 
23: begin note = SP; duration = HALF; end 
24: begin note = G4; duration = HALF; end 
25: begin note =SP; duration = HALF; end
26: begin note = Gs; duration = HALF; end 
27: begin note = SP; duration = HALF; end 

28: begin note = G4; duration = HALF; end 
29: begin note = F4; duration = HALF; end 
30: begin note = SP; duration = HALF; end 
31: begin note = Ds; duration = HALF; end 
32: begin note = SP; duration = HALF; end 
33: begin note = D4; duration = HALF; end 
34: begin note = SP; duration = HALF; end 
35: begin note = C4; duration = HALF; end 
36: begin note = SP; duration = HALF; end 
37: begin note = C4; duration = HALF; end 
38: begin note = SP; duration = HALF; end 
39: begin note = C4; duration = ONE; end 
40: begin note = SP; duration = HALF; end

default: begin note = C4; duration = FOUR; end
endcase
end
endmodule

module SongPlayer( input clock, input playSound, output reg 
audioOut, output wire aud_sd);
reg [19:0] counter;
reg [31:0] time1, noteTime;
reg [9:0] msec, number; //millisecond counter, and sequence number of musical note.
wire [4:0] note, duration;
wire [19:0] notePeriod;
wire one;
integer x=0;
parameter clockFrequency = 100_000_000;
slowerClkGen s1 (clock,50_000_000,one);
always@(posedge one&&playSound)
begin
x=x+1;
end
assign aud_sd = 1'b1;
MusicSheet  mysong(number, notePeriod, duration );
always @ (posedge clock) 
  begin
if(~playSound||x>5) 
 begin 
          counter <=0;  
          time1<=0;  
          number <=0;  
          audioOut <=1;
      end
else 
begin
counter <= counter + 1; 
time1<= time1+1;
if( counter >= notePeriod) 
   begin
counter <=0;  
audioOut <= ~audioOut ; 
   end //toggle audio output 
if( time1 >= noteTime) 
begin
time1 <=0;  
number <= number + 1; 
end  //play next note
 if(number == 48) number <=0; // Make the number reset at the end of the song
end
  end
         
  always @(duration) noteTime = (duration * clockFrequency/8); 
       //number of   FPGA clock periods in one note.
endmodule   


