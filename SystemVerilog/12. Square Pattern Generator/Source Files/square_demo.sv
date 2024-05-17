/*-======================================================================
-- Description: generate a 3-level test bar pattern:
--   * gray scale 
--   * 8 prime colors
--   * a continuous color spectrum
--   * it is customized for 12-bit VGA
--   * two registers form 2-clock delay line  
--======================================================================*/

module square_demo 
   (
    input  logic [10:0] x, y,     // treated as x-/y-axis
    input logic [1:0] side_width, 
    input logic [11:0] square_rgb,
    output logic [11:0] bar_rgb 
   );

   // declaration
   logic [3:0] up, down;
   logic [3:0] r, g, b;
   logic [7:0] width;
   localparam center_x = 320;
   localparam center_y = 240;
   logic r_back, g_back, b_back;
   
   // ------------------------------- body
   assign up = x[6:3];
   assign down = ~x[6:3];    // "not" reverse the binary sequence 
   
   always_comb
   begin
    unique case (side_width) 
         2'b00: 
         begin
            width = 16;
         end   
         2'b01: 
         begin
            width = 32;      
         end   
         2'b10: 
         begin
            width = 64;
         end   
         2'b11: 
         begin
            width = 128;  
         end   
     endcase
   
    if (y > (center_y - width) && y < (center_y + width) && x > (center_x - width) && x < (center_x + width))                   // This code displays a squre with width 200 in the middle of the screen 
    begin
        r = {square_rgb[3:0]};
        g = {square_rgb[7:4]};
        b = {square_rgb[11:8]};
        //r = 4'b1111;
        //g = 4'b0000;
         //b = 4'b0000;
    end
    else
    begin
//         r_back = 4'b1111 - r;
//         g_back = 4'b1111 - g;
//         b_back = 4'b1111 - b;
        r = 4'b1111 - {square_rgb[3:0]} ;
        g = 4'b1111 - {square_rgb[7:4]};
        b = 4'b1111 - {square_rgb[11:8]} ;
    end
   
    
/*      // 16 shades of gray
      if (y < 128) 
      begin
         r = x[8:5];
         g = x[8:5];
         b = x[8:5];
      end   
      // 8 prime colors with 50% intensity
      else if (y < 256) 
      begin
         r = {x[8], x[8], 2'b00};
         g = {x[7], x[7], 2'b00};
         b = {x[6], x[6], 2'b00};
      end
      else 
      begin   
      // a continuous color spectrum 
      // width of up/sown can be increased to accommodate finer spectrum
      // see Fig 23 of http://en.wikipedia.org/wiki/HSL_and_HSV
      unique case (x[9:7]) 
         3'b000: begin
            r = 4'b1111;
            g = up;
            b = 4'b0000;
         end   
         3'b001: begin
            r = down;
            g = 4'b1111;
            b = 4'b0000;
         end   
         3'b010: begin
            r = 4'b0000;
            g = 4'b1111;
            b = up;
         end   
         3'b011: begin
            r = 4'b0000;
            g = down;
            b = 4'b1111;
         end   
         3'b100: begin
            r = up;
            g = 4'b0000;
            b = 4'b1111;
         end   
         3'b101: begin
            r = 4'b1111;
            g = 4'b0000;
            b = down;
         end   
         default: begin
            r = 4'b1111;
            g = 4'b1111;
            b = 4'b1111;
         end  
         endcase
      end // else*/
   end // always   
   
   // output
   assign bar_rgb = {b, g, r};
endmodule