`timescale 1ns / 1ps


//================================= Top Module =============================
module top_module
    (
    input logic clk,
    input logic [7:0] sw1,                              //address
    input logic sw_cf,
        
    output logic [6:0] sseg,
    output logic [7:0] AN
    );
     
     
    logic [7:0] data_f;
    logic [7:0] data_c;
    logic [7:0] data_mux;
 
    
    //---------------------------------- BRAM f
    synch_rom_f f_rom
        (
        .clk(clk),
        .addr(sw1),
    
        .data(data_f)
        );   
    //---------------------------------- BRAM c    
    synch_rom_c c_rom
        (
        .clk(clk),
        .addr(sw1),
    
        .data(data_c)
        );

    //------------------------------------ mux
    always_comb 
    begin 
        if (sw_cf)
            data_mux = data_f;
        else
            data_mux = data_c;
    end
    
    
    
    
    
    //---------------------------------- binary to BCD
    logic [3:0] ones_addr;
    logic [3:0] tens_addr;
    logic [3:0] hundreds_addr;
    
    logic [3:0] ones_data;
    logic [3:0] tens_data;
    logic [3:0] hundreds_data;
    
    binary_2_BCD addr_BCD                           // addr BCD
        (
        .sw(sw1),          
        
        .ones(ones_addr),
        .tens(tens_addr),
        .hundreds(hundreds_addr)
        );
        
        
    binary_2_BCD data_BCD
        (
        .sw(data_mux),                
        
        .ones(ones_data),
        .tens(tens_data),
        .hundreds(hundreds_data)
        );    
    
    
    //----------------------------- 7 segments display 
    logic [3:0] cf_led, cf_led_2;
    assign cf_led = sw_cf ? 4'b1111 : 4'b1100;       // output
    assign cf_led_2 = sw_cf ? 4'b1100 : 4'b1111;    //input
    
//    logic hundreds_f_AN;
//    logic hundreds_c_AN;
//    logic tens_c_AN;
    
//    assign hundreds_f_AN = (hundreds_f == 4'b0000) ? 1'b0 : 1'b1;
//    assign hundreds_c_AN = (hundreds_c == 4'b0000) ? 1'b0 : 1'b1;
//    assign tens_c_AN     = (tens_c == 4'b0000 && hundreds_c == 4'b0000)     ? 1'b0 : 1'b1;
    
    time_mux_disp disp 
        (
        .in0({1'b1 , ones_addr, 1'b1}),                                      //addr
        .in1({1'b1 , tens_addr, 1'b1}),
        .in2({1'b1 , hundreds_addr, 1'b1}),
        .in3({1'b1, cf_led_2, 1'b1}),                                       // c or f
        //------------------------------
        .in4({1'b1 ,cf_led, 1'b1}),                                          // c or f 
        .in5({1'b1 , ones_data, 1'b1}),            
        .in6({1'b1 , tens_data, 1'b1}),
        .in7({1'b1 , hundreds_data, 1'b1}), 
              
        .clk(clk),
        
        .sseg(sseg),
        .dp(),
        .an(AN)
        );
    
endmodule    
    
