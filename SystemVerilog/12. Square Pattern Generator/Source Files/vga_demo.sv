module vga_demo 
   #(parameter CD = 12)    // color depth
   (
    input  logic clk,
    input  logic [15:0] sw,
    // to vga monitor
    output logic hsync, vsync,
    output logic[CD-1:0] rgb
   );

   // logic [CD-1:0] declaration
   logic [10:0] hc, vc;
   logic [CD-1:0] bar_rgb, back_rgb, gray_rgb, color_rgb, vga_rgb;
   logic [CD-1:0] bypass_bar, bypass_gray;
   logic [1:0] width;
   
   // body
   // use switches to set background color
   assign back_rgb = sw[11:0];                                // 12-bits for colors
   assign width = sw[13:12];
   assign bypass_bar = sw[14];                               
   assign bypass_gray = sw[15];                                //    ------------------------------- we need to edit this
   
   
   // ------------------------- pattern generator
   square_demo square_unit
   (
        .x(hc), 
        .y(vc),
        .side_width(width),
        .square_rgb(back_rgb),
        .bar_rgb(bar_rgb)
    );
    
    
   // -------------------------- instantiate color-to-gray conversion circuit
   rgb2gray c2g_unit  
   (
        .color_rgb(color_rgb), 
        .gray_rgb(gray_rgb)
    );
    
    
   // ---------------------------- instantiate video synchronization circuit
   vga_sync_demo #(.CD(CD)) sync_unit
   (
        .clk(clk), 
        .reset(0), 
        .vga_si_rgb(vga_rgb),
        .hsync(hsync), 
        .vsync(vsync), 
        .rgb(rgb), 
        .hc(hc), 
        .vc(vc)
    );  
    
   // video source selection mux #1  
   assign color_rgb = (bypass_bar) ? back_rgb : bar_rgb;
   // video source selection mux #0  
   assign vga_rgb = (bypass_gray) ? color_rgb : gray_rgb;
endmodule