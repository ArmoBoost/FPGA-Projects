`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 





//================================= early debouncer circuit (different from the delayed debouncer) =========================================
module early_debouncer(
        input logic sw,
        input logic reset,
        input logic clk,                            // genrally the 100MHz
        output logic db
    );

    
    //------------------- 10 ms counter ----------------------
    // M = 1_000_000
    logic m_tick;
    mod_m_counter #(.M(5)) ticker (                              // 10 ms m_tick generator
                    .clk(clk),                                           // assuming clk is 100 MHz (clock period is 10 ns)
                    .reset(reset),                                       // 10 ms / 10 ns is 10e-3 / 10e-9 which is 1_000_000
                    .max_tick(m_tick)                                    // if your clk freq is 100MHz, then you need a million count (1_000_000) to get to 10ms
    );
    
    
    
    // There is a bug somewhere here, if you click the switch many times and fast enough the output disappears
    // typedef enum {zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3} state_type;    
    // signal declarations
    // state_type state_reg, state_next;   
    
    // symbolic state declaration 
    localparam [2:0] zero    = 3'b000, 
                     wait1_1 = 3'b001, 
                     wait1_2 = 3'b010, 
                     wait1_3 = 3'b011, 
                     one     = 3'b100, 
                     wait0_1 = 3'b101,                       
                     wait0_2 = 3'b110,
                     wait0_3 = 3'b111;
    logic [2:0] state_reg , state_next ;
    
    
    
    
    // ----------------- [1] State register
    always_ff @(posedge clk, posedge reset)
        if(reset)
            state_reg <= zero;
        else
            state_reg <= state_next;
            
    
    // ----------------- [2] next-state logic
    always_comb
    begin
        //db = 0;
        case(state_reg)
            zero:                                            // ---- Zero
                    begin 
                    db = 0;
                    if(sw)
                        state_next = wait1_1;
                    else
                        state_next = zero;
                    end
            wait1_1:                                         // ---- wait1_1
//                    if(sw)
                        if(m_tick)
                            state_next = wait1_2;
                        else
                            state_next = wait1_1;
//                    else
//                        state_next = zero;
            wait1_2:                                         // ---- wait1_2
//                     if(sw)
                        if(m_tick)
                            state_next = wait1_3;
                        else
                            state_next =  wait1_2;
//                    else
//                        state_next = zero;                   
            wait1_3:                                         // ---- wait1_3
//                     if(sw)
                        if(m_tick)
                            state_next = one;
                        else 
                            state_next = wait1_3;
//                    else
//                        state_next = zero;    
                        
            one:                                             // ---- one
                    if(~sw)
                        state_next = wait0_1;
                    else
                        state_next = one;
            wait0_1:                                         // ---- wair0_1
//                    if(~sw)
                        if(~m_tick)
                            state_next = wait0_1;
                        else
                            state_next = wait0_2;
//                    else
//                        state_next = one;
            wait0_2:                                         // ---- waiet0_2
//                     if(~sw)
                        if(~m_tick)
                            state_next = wait0_2;
                        else 
                            state_next = wait0_3;
//                    else
//                        state_next = one;                   
            wait0_3:                                         // ---- wait0_3
//                     if(~sw)
                        if(~m_tick)
                            state_next = wait0_3;
                        else
                            state_next = zero;
//                    else
//                        state_next = one; 
            default: state_next = zero;
        endcase
    end
    
    // Moore output logic
    assign db = (   (state_reg == one) || 
                    (state_reg == wait1_1) || 
                    (state_reg == wait1_2) || 
                    (state_reg == wait1_3));
endmodule
