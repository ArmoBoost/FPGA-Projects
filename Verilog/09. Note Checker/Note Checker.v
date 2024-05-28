`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2023 03:02:45 PM
// Design Name: 
// Module Name: top
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


module top(clk,playSound,reset,resetLight,rc,lc,uc,dc,
sevenSeg,AN,audioOut,aud_sd);
input clk,reset,rc,lc,playSound,uc,dc;
output audioOut, aud_sd,resetLight;
output wire [7:0] sevenSeg;//actual display
wire [7:0]displayNote,displaySharp,displaySelect;
output [7:0] AN;
reg sharp;
assign resetLight=reset;
localparam[3:0] C=4'b0011,Db=4'b0100,D=3'b0101
,Eb=4'b0110,E=4'b0111,F=4'b1000,Gb=4'b1001,G=4'b1010 , Ab=4'b1011,A=4'b1100, Bb=4'b1101,B=4'b1110;

localparam[1:0] Custom=2'b00,Guitar=2'b01, Bass=2'b10, Uk=2'b11;

wire slowClk;
slowerClkGen slow1(clk,7_500_000,slowClk);
assign slowShow=slowClk;

reg [3:0]state_reg,state_next;
reg [1:0] sel_reg,sel_next;
seven_seg(state_reg,sharp,sel_reg,displayNote,displaySelect,displaySharp);
noteDisplay(clk,displayNote,displaySelect,displaySharp,AN,sevenSeg);
SongPlayer( clk, playSound, audioOut, aud_sd,state_reg);

always@(posedge slowClk,posedge reset)
    if(reset)
        sel_reg<=Custom;
    else
        sel_reg<=sel_next;
    
    
always@*
    begin
    sel_next=sel_reg;
    
    case(sel_reg)
    
    Custom:
        begin
            if(uc)
                sel_next=Uk;
            if(dc)
                sel_next=Guitar;
         end
        
    Guitar:
        begin
            if(uc)
                sel_next=Custom;
            if(dc)
                sel_next=Bass;
        end
     
     Bass:
        begin
            if(uc)
                sel_next=Guitar;
            if(dc)
                sel_next=Uk;
        end
        
      Uk:
        begin
            if(uc)
                sel_next=Bass;
            if(dc)
                sel_next=Custom;
        end
     default:
        sel_next=Guitar;
     endcase
     end

always@(posedge slowClk, posedge reset)
    if(reset)
        state_reg<=C;
    else
        state_reg<=state_next;
        
always@*
    begin
    state_next=state_reg;
    case(state_reg)
    
    C:
        begin
        sharp=1'b0;
            if(sel_reg==Custom)
                begin
                 if(rc)
                    begin
                    state_next=Db;
                 
                 end
                 if(lc)
                 state_next=B;
              end
              
              else if(sel_reg==Guitar)
                    state_next=E;
                    
              else if(sel_reg==Bass)
                    state_next=E;
              else if(sel_reg==Uk)
              begin
                if(rc)
                    state_next=E;
                if(lc)
                    state_next=G;
              end
        end
    Db:
        begin
        sharp=1'b1;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=D;
       
                if(lc)
                state_next=C;
         end
              
         else if(sel_reg==Guitar)
                    state_next=E;
                    
         else if(sel_reg==Bass)
                    state_next=E;
         else if(sel_reg==Uk)
                    state_next=G;     
         end
             
        D:
        begin
        sharp=1'b0;
        if(sel_reg==Custom)
            begin
                if(rc)
                    state_next=Eb;
     
                 if(lc)
                    state_next=Db;
         end
         
         else if(sel_reg==Guitar)
            begin
            if(rc)
                state_next=G;
            else if(lc)
                state_next=A;
            end
                    
         else if(sel_reg==Bass)
            begin
            if(rc)
                state_next=G;
            else if(lc)
                state_next=A;
            end   
            
         else if(sel_reg==Uk)
                    state_next=G;      
         end
        
        Eb:
        begin
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=E;
       
                if(lc)
                state_next=D;
         end
              
         else if(sel_reg==Guitar)
                    state_next=E;
                    
         else if(sel_reg==Bass)
                    state_next=E;
          else if(sel_reg==Uk)
                    state_next=G;
         end
             
        E:
        begin
        sharp=1'b0;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=F;
       
                if(lc)
                state_next=Eb;
         end
              
         else if(sel_reg==Guitar)
            begin
            if(rc)
                state_next=A;
            else if(lc)
                state_next=B;
            end
                    
         else if(sel_reg==Bass)
            begin
            if(rc)
                state_next=A;
            else if(lc)
                state_next=G;
            end      
            
         else if(sel_reg==Uk)
            begin
            if(rc)
                state_next=A;
            else if(lc)
                state_next=C;
            end            
        end
             
         F:
        begin
        sharp=1'b0;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=Gb;
       
                if(lc)
                state_next=E;
         end
              
         else if(sel_reg==Guitar)
                    state_next=E;
                    
         else if(sel_reg==Bass)
                    state_next=E;
                    
         else if(sel_reg==Uk)
                    state_next=G;
                     
             end
             
         Gb:
        begin
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=G;
       
                if(lc)
                state_next=F;
         end
              
         else if(sel_reg==Guitar)
                    state_next=E;
                    
         else if(sel_reg==Bass)
                    state_next=E;
                    
         else if(sel_reg==Uk)
                    state_next=G;
                     
             end
         G:
        begin
        sharp=1'b0;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=Ab;
       
                if(lc)
                state_next=Gb;
         end
              
         else if(sel_reg==Guitar)
            begin
            if(rc)
                state_next=B;
            else if(lc)
                state_next=D;
            end
                    
         else if(sel_reg==Bass)
            begin
            if(rc)
                state_next=E;
            else if(lc)
                state_next=D;
            end     
            
          else if(sel_reg==Uk)
            begin
            if(rc)
                state_next=C;
            else if(lc)
                state_next=A;
            end     
             end
             
             Ab:
        begin
        sharp=1'b1;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=A;
       
                if(lc)
                state_next=G;
         end
              
         else if(sel_reg==Guitar)
                    state_next=E;
                    
         else if(sel_reg==Bass)
                    state_next=E;
                    
         else if(sel_reg==Uk)
                    state_next=G;
              
             end
             
        A:
        begin
        sharp=1'b0;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=Bb;
       
                if(lc)
                state_next=Ab;
         end
              
         else if(sel_reg==Guitar)
            begin
            if(rc)
                state_next=D;
            else if(lc)
                state_next=E;
            end
                    
         else if(sel_reg==Bass)
            begin
            if(rc)
                state_next=D;
            else if(lc)
                state_next=E;
            end  
            
         else if(sel_reg==Uk)
            begin
            if(rc)
                state_next=G;
            else if(lc)
                state_next=E;
            end     
                     
             end
             
        Bb:
        begin
        sharp=1'b1;
        if(sel_reg==Custom)
            begin
                if(rc)
                state_next=B;
       
                if(lc)
                state_next=A;
         end
              
         else if(sel_reg==Guitar)
                    state_next=E;
                    
         else if(sel_reg==Bass)
                    state_next=E;
                    
         else if(sel_reg==Uk)
                    state_next=G;
             end
             
             
        B:
        begin
        sharp=1'b0;
            if(sel_reg==Custom)
            begin
                if(rc)
                state_next=C;
       
                if(lc)
                state_next=Bb;
         end
              
         else if(sel_reg==Guitar)
            begin
            if(rc)
                state_next=E;
            else if(lc)
                state_next=G;
            end
                    
         else if(sel_reg==Bass)
            begin
            if(rc)
                state_next=E;
            else if(lc)
                state_next=E;
                     
             end
             
          else if(sel_reg==Uk)
                    state_next=G;
             end
             
             
             
     default:
     state_next=A;
     endcase
     end
endmodule

module seven_seg(input [3:0] state,input sharp,input [1:0]sel,output reg [7:0] leds,output reg[7:0] selectLeds,output reg[7:0] sharpLED);
always@*
    if(sharp==1'b1)
            sharpLED=8'b10000011;
        else if(sharp==1'b0)
            sharpLED=8'b11111111;
            
always@*
    if(sel==2'b00)
        selectLeds=8'b11000110;
    else if(sel==2'b01)
        selectLeds=8'b10000010; 
    else if(sel==2'b10)
        selectLeds=8'b10000011;
    else if(sel==2'b11)
        selectLeds=8'b11000001;


always@* 
    begin
       if(state==4'b1011||state==4'b1100)//A
            leds=8'b10001000;
       else if(state==4'b1101||state==4'b1110)//B
            leds=8'b10000011;
       else if(state==4'b0011)//C
            leds=8'b11000110;
       else if(state==4'b0100||state==4'b0101)//D
            leds=8'b10100001;
       else if(state==4'b0110||state==4'b0111)//E
            leds=8'b10000110;
       else if(state==4'b1000)//F
            leds=8'b10001110;
       else if(state==4'b1001||state==4'b1010)//G
            leds=8'b10000010; 
       else
            leds=8'b11111111;
            
    end
endmodule

module MusicSheet( input [9:0] number,
output reg [19:0] note,//what is the max frequency  
output reg [4:0] duration,
input [3:0] state_reg);
parameter   QUARTER = 5'b00010; 
parameter HALF = 5'b00100;
parameter ONE = 2* HALF;
parameter TWO = 2* ONE;
parameter FOUR = 2* TWO;
parameter A=113_636,Bb=107_259,B=101_239,C=95_556,Db=90_192,
D=85_131,Eb=80_353,E=75_843,F=71_586,Gb=67_568,G=63_776,Ab=60_196;
reg currentNote;
always @ (number) begin
case(number)
        0: begin 
            if(state_reg==4'b0000)
                begin
                    note = C; 
                    duration = HALF; 
                end
            if(state_reg==4'b0001)
                begin
                    note = Db; 
                    duration = HALF; 
                end
                
             if(state_reg==4'b0010)
                begin
                    note = D; 
                    duration = HALF; 
                end
              if(state_reg==4'b0011)
                begin
                    note = Eb; 
                    duration = HALF; 
                end
            if(state_reg==4'b0100)
                begin
                    note = E; 
                    duration = HALF; 
                end
                
             if(state_reg==4'b0101)
                begin
                    note = F; 
                    duration = HALF; 
                end
             if(state_reg==4'b0110)
                begin
                    note = Gb; 
                    duration = HALF; 
                end
                
                if(state_reg==4'b0111)
                begin
                    note = G; 
                    duration = HALF; 
                end
                
                if(state_reg==4'b1000)
                begin
                    note = Ab; 
                    duration = HALF; 
                end
                
                if(state_reg==4'b1001)
                begin
                    note = A; 
                    duration = HALF; 
                end
                
                if(state_reg==4'b1001)
                begin
                    note = Bb; 
                    duration = HALF; 
                end
                
                if(state_reg==4'b1010)
                begin
                    note = B; 
                    duration = HALF; 
                end
        end 


default: begin note = C; duration = FOUR; end
endcase
end
endmodule

module SongPlayer( input clock, input playSound, output reg 
audioOut, output wire aud_sd,input [2:0] state_reg);
reg [19:0] counter;
reg [31:0] time1, noteTime;
reg [9:0] msec, number; //millisecond counter, and sequence number of musical note.
wire [4:0] note, duration;
wire [19:0] notePeriod;
integer x=0;
parameter clockFrequency = 100_000_000;
assign aud_sd = 1'b1;
MusicSheet  mysong(number, notePeriod, duration,state_reg );
always @ (posedge clock) 
  begin
if(~playSound) 
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

module noteDisplay(input clk,input [7:0] note,input[7:0] select,input [7:0] sharp,output reg [7:0] AN,output reg[7:0] Cx);
    wire slowClk;
    wire [2:0]S;
    slowerClkGen muxClock(clk,125_000,slowClk);
    upcounter muxCount(slowClk,1'b1,S);
    
    always@*
    if(S==3'b000)
    begin
        AN=8'b11111101;
        Cx=note;
    end
    
    else if(S==3'b001)
        begin
        AN=8'b11111110;
        Cx=sharp;
        end
        
    else if(S==3'b010)
        begin
        AN=8'b01111111;
        Cx=select;
        end
       
    else if(S==3'b011)
        begin
        AN=8'b10111111;
        Cx=8'b10111111;
        end  
        
    else if(S==3'b100)
        begin
        AN=8'b11011111;
        Cx=8'b10111111;
        end   
        
    else if(S==3'b101)
        begin
        AN=8'b11101111;
        Cx=8'b10111001;
        end       
endmodule

module upcounter (Clock, E, Q);
    input Clock, E;
    output reg [2:0]Q;
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
    if (counter == HZ) 
    begin
    outsignal=~outsignal;
    counter =0;
    end
   end
endmodule