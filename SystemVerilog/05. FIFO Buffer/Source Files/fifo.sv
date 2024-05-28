`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////




//================================= Top Module ======================================== 
module fifo
    (
        input logic clk, reset,
        input logic wr, rd,
        input logic [15: 0] w_data,                         // 16-bit
        
        output logic [7: 0] r_data,                        // 8-bit
        output logic full, empty
    );
    
    // signal declaration
    logic [2: 0] w_addr, r_addr;
    
    
    
    
    // --------------------- instantiate register file
    reg_file
        r_file_unit 
        (
            .clk(clk), 
            .w_en(wr & ~full ), 
            .w_addr(w_addr), 
            .r_addr(r_addr),          
            .w_data(w_data),         //16-bit
            .r_data(r_data)          //8-bit
        );


    // ----------------------- instantiate fifo controller
    fifo_ctrl
        ctrl_unit 
        (
            .clk(clk), 
            .reset(reset), 
            .wr(wr), 
            .rd(rd), 
            .full(full), 
            .empty(empty), 
            .w_addr(w_addr), 
            .r_addr(r_addr)
        ); 
        
        
                           
endmodule
