`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2023 01:38:33 PM
// Design Name: 
// Module Name: MusicSheet
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

module SongPlayer( input clock, input reset, input playSound, output reg 
audioOut, output wire aud_sd);
reg [19:0] counter;
reg [31:0] time1, noteTime;
reg [9:0] msec, number; //millisecond counter, and sequence number of musical note.
wire [4:0] note, duration;
wire [19:0] notePeriod;
parameter clockFrequency = 100_000_000; 
assign aud_sd = 1'b1;
MusicSheet  mysong(number, notePeriod, duration );
always @ (posedge clock) 
  begin
if(reset | ~playSound) 
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