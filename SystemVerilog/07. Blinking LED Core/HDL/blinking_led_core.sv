



//============================================== output slot: Write to LEDs =================================================
module blinking_led_core
   #(parameter width = 16)       // width of each register
   (
    input  logic clk,
    input  logic reset,

    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,

    // external port    
    output logic [3:0] led_output                   // 4-bit output = 4 LEDs
   );

   // declaration
   // Registers to hold the blinking intervals for each LED
   logic [width-1:0] buf_reg0, buf_reg1, buf_reg2, buf_reg3;
   
   logic wr_en0;
   logic wr_en1;
   logic wr_en2;
   logic wr_en3;
   
   logic sq_wave0, sq_wave1, sq_wave2, sq_wave3;
   
   
   // ------------------------------------------------- body -----------------------------------------
   // output registers
   always_ff @(posedge clk, posedge reset)
      if (reset)
      begin
         buf_reg0 <= 0;
         buf_reg1 <= 0;
         buf_reg2 <= 0;
         buf_reg3 <= 0;
      end
      else  
      begin 
         if (wr_en0)
            buf_reg0 <= wr_data[width-1:0];                        // here: The data that is written (intervels) in the application level
         else if (wr_en1)                                          // gets stored in the each register 
            buf_reg1 <= wr_data[width-1:0]; 
         else if (wr_en2)
            buf_reg2 <= wr_data[width-1:0];
         else if (wr_en3)
            buf_reg3 <= wr_data[width-1:0];
                
      end
   
   
   // --------- decoding logic
   assign wr_en0 = (write && cs && (addr[1:0]==2'b00));              
   assign wr_en1 = (write && cs && (addr[1:0]==2'b01));
   assign wr_en2 = (write && cs && (addr[1:0]==2'b10));
   assign wr_en3 = (write && cs && (addr[1:0]==2'b11));
   
   
   
   //------------------- LED 0 Output wave  
   square_wave_generator sq_wave_0
   (
        .clk(clk),
        .reset(reset),
        .interval(buf_reg0),
        .sq_wave(sq_wave0)     
   );   
   
   //------------------- LED 1 Output wave  
   square_wave_generator sq_wave_1
   (
        .clk(clk),
        .reset(reset),
        .interval(buf_reg1),
        .sq_wave(sq_wave1)     
   );    

   //------------------- LED 2 Output wave  
   square_wave_generator sq_wave_2
   (
        .clk(clk),
        .reset(reset),
        .interval(buf_reg2),
        .sq_wave(sq_wave2)     
   );    

   //------------------- LED 3 Output wave  
   square_wave_generator sq_wave_3
   (
        .clk(clk),
        .reset(reset),
        .interval(buf_reg3),
        .sq_wave(sq_wave3)     
   );     
     
    
    // --------- slot read interface
    assign rd_data =  0;  
    
    // --------- external output 
    assign led_output[0] = sq_wave0;
    assign led_output[1] = sq_wave1;
    assign led_output[2] = sq_wave2;
    assign led_output[3] = sq_wave3;
     
endmodule



         
//================================================= square wave generator with equal intervals ============================================== 
module square_wave_generator(
    input logic clk,
    input logic reset,
    input logic [15:0] interval,
    output logic sq_wave
    );

    logic [15:0] count;
    logic r_next, r_reg;
    logic ms_tick;
     
    // ------------------------- 1 millisecond counter
    counter_1ms counter
    (
        .clk(clk),
        .reset(reset),
        .ms_tick(ms_tick)
    ); 
    
    // ------------------------- [1] Register segment
    always_ff @(posedge clk, posedge reset)
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    
    
    // ------------------------- [2] next-state logic segment
    always @(posedge ms_tick) 
    begin
        count = count + 1;                                   // increments count by 1 every millisecond
        
        if (count > interval)
            count = 0;                                       // --> This setup creates a blinking pattern where the LED 
        else if (count < interval[15:1])                     // is off for the first half of the target duration and 
            r_next = 0;                                      // then on for the second half. The target value essentially
        else if (count >= interval[15:1])                    // defines the total cycle time in milliseconds for the blinking pattern.
            r_next = 1;                                      // --> [15:1] This operation effectively performs a right shift by 1 bit on 
     end                                                     // the target value, which mathematically is equivalent to dividing the value by 2
     

    // ------------------------ [3] output logic segment  
    assign sq_wave = r_reg;

endmodule


//============================ 1 millisecond counter ==========================================
//============================ In other words, slow clock generator to 1ms clk
module counter_1ms 
    (
        input logic clk,
        input logic reset,
        output logic ms_tick
    ); 
    
    logic [20:0] count_reg, count_next;
    logic [20:0] target = 20'b0001_1000_0110_1010_0000;                // 1 millisecond exactly
    
    
    always_ff @(posedge clk, posedge reset)
        if(reset)
            count_reg <= 0;
        else
            count_reg <= count_next;
     
     
          
     always_comb
        if (count_reg == target)
             begin
                ms_tick = 1;
                count_next = 0;
            end
        else
            begin
                ms_tick = 0;
                count_next = count_reg + 1;
            end
          
endmodule
   
   
 
       
