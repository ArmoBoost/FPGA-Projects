`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2023 01:23:25 PM
// Design Name: 
// Module Name: lab10
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
module top(input wire clk,reset1,reset2,level1,level2,
output tick1, output tick2,disClock);
wire db1,db2;
db(clk,reset1,level1,db1);
db(clk,reset2,level2,db2);

edge_detect_moore(clk,reset1,db1,tick1,disClock);
edge_detect_mealy(clk,reset2,db2,tick2);


endmodule

module edge_detect_moore (input wire clk, reset, level,
output reg tick,output slowClk);
    slowerClkGen s1(clk,50_000_000,slowClk);
    localparam [1:0] zero=2'b00, edg=2'b01, one=2'b10;
    reg[1:0] state_reg, state_next;
    always @(posedge slowClk, posedge reset)
        if (reset)
            state_reg<=zero;
        else
            state_reg<=state_next;
    always@*
        begin
            state_next=state_reg;
            tick=1'b0; //default output
            case (state_reg)
                zero:
                begin
                    tick=1'b0;
                    if (level)
                        state_next=edg;
                end
                edg:
                    begin
                        tick=1'b1;
                        if (level)
                            state_next=one;
                        else
                            state_next=zero;
                    end
                one:
                    if (~level)
                        state_next=zero;
                default: state_next=zero;
                    endcase
        end
    endmodule
    
    module edge_detect_mealy (input wire clk, reset2, level2,
output reg tick2);
slowerClkGen s0(clk,50_000_000,slowClk);
wire slowClk;
localparam zero=1'b0, one=1'b1;
reg state_reg, state_next;
always @(posedge slowClk, posedge reset2)
if (reset2)
state_reg<=zero;
else
state_reg<=state_next;
always@*
begin
state_next=state_reg;
tick2=1'b0;
case (state_reg)
zero:
if (level2)
begin
tick2=1'b1; //this change is immediate
state_next=one;
end
one:
if (~level2)
state_next=zero;
default:
state_next=zero;
endcase
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
///////////////
module db (
    input wire clk, reset,
    input wire sw,
    output reg db
);

// Symbolic state declaration
localparam [2:0]
    zero = 3'b000,
    waitl_1 = 3'b001,
    waitl_2 = 3'b010,
    waitl_3 = 3'b011,
    one = 3'b100,
    wait0_1 = 3'b101,
    wait0_2 = 3'b110,
    wait0_3 = 3'b111;

// Number of counter bits (2^N * 2^Ons = 10ms tick)
localparam N = 19;

// Signal declaration
reg [N-1:0] q_reg;
wire [N-1:0] q_next;
wire m_tick;
reg [2:0] state_reg, state_next;

// Counter to generate 10ms tick
always @(posedge clk)
    q_reg <= q_next;

// Next-state logic
assign q_next = q_reg + 1;

// Output tick
assign m_tick = (q_reg == 0) ? 1'b1 : 1'b0;

// Debouncing FSM
// State register
always @(posedge clk, posedge reset)
    if (reset)
        state_reg <= zero;
    else
        state_reg <= state_next;

// Next-state logic and output logic
always @*
begin
    state_next = state_reg; // Default state: the same
    db = 1'b0; // Default output: 0
    
    case (state_reg)
        zero:
            if (sw)
                state_next = waitl_1;
        waitl_1:
            if (!sw)
                state_next = zero;
            else if (m_tick)
                state_next = waitl_2;
        waitl_2:
            if (!sw)
                state_next = zero;
            else if (m_tick)
                state_next = waitl_3;
        waitl_3:
            if (!sw)
                state_next = zero;
            else if (m_tick)
                state_next = one;
        one:
            begin
                db = 1'b1;
                if (!sw)
                    state_next = wait0_1;
            end
        wait0_1:
            begin
                db = 1'b1;
                if (sw)
                    state_next = one;
                else if (m_tick)
                    state_next = wait0_2;
            end
        wait0_2:   
            begin
                db = 1'b1;
                if (sw)
                    state_next = one;
                else if (m_tick)
                    state_next = wait0_3;
            end
        wait0_3:
            begin
                db = 1'b1;
                if (sw)
                    state_next = one;
                else if (m_tick)
                    state_next = zero;
            end
        default: state_next = zero;
    endcase
end

endmodule
