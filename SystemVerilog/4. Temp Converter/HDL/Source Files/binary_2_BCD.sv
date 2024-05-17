`timescale 1ns / 1ps


module binary_2_BCD
    (
    input logic [7:0] sw,
    
    output logic [3:0] ones,
    output logic [3:0] tens,
    output logic [3:0] hundreds
    );
    
          
    always_comb 
    begin 
        ones = sw % 10;                           //0001_0000(16) = 16 % 10 = 6       0110_0100 (100) -- 100 % 10 = 0              1111_1111(255) -- 255 % 10 = 5
        tens = (sw/10) % 10 ;                   // 16/10 = 1                                          (100 % 10) % 10 = 0                       -- (255%100) / 10 = 5
        hundreds = sw / 100;               // 16/100 = 0                                          (100 / 10) / 10 = 1                       -- (255/10) /10 = 2
    end   
endmodule
