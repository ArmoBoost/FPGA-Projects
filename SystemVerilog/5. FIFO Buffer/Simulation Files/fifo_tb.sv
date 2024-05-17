`timescale 1ns / 1ps








//---------------------------------------------------- Test Bench -----------------------------------------
module fifo_tb();
    
    
    // signal declarations
    //localparam DATA_WIDTH = 8;
    //localparam ADDR_WIDTH = 3;
    
    localparam T = 10; //clock period
    
    logic clk, reset;
    logic wr, rd;
    logic [15 : 0] w_data; 
    logic [7 : 0] r_data;
    logic full, empty;
    
    // instantiate module under test
    //fifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) uut (.*);
    fifo uut 
    (
        .*
    );
    
    
    // -------------------- 10 ns clock running forever
    always
    begin
        clk = 1'b1;
        #(T / 2);
        clk = 1'b0;
        #(T / 2);
    end
    
    // --------------------- reset for the first half cylce
    initial
    begin
        reset = 1'b1;
        rd = 1'b0;
        wr = 1'b0;
        @(negedge clk);
        reset = 1'b0;
    end
    
    // -------------------------------------------------- test vectors
    initial
    begin
        // ----------------EMPTY-----------------------
        // write
        @(negedge clk);
        w_data = 16'haa09;                                //in address = 0
        wr = 1'b1;     
        @(negedge clk);
        wr = 1'b0;
        
        // write
        repeat(1) @(negedge clk);
        w_data =16'hbb08;                                //in address = 1
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;
        
        // write
        repeat(1) @(negedge clk);
        w_data = 16'hcc02;                                //in address = 2
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;        
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;                          //read address = 0
        @(negedge clk)
        rd = 1'b0;        
        
        // write
        repeat(1) @(negedge clk);
        w_data = 16'hdd05;                                //in address = 3
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;        
        
        // write
        repeat(1) @(negedge clk);
        w_data = 16'hee06;                                //in address = 4
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;        
        
        // write
        repeat(1) @(negedge clk);
        w_data = 8'd3;                                //in address = 5
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;        
        
        // write
        repeat(1) @(negedge clk);
        w_data = 8'd6;                                //in address = 6
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;        
        
        // write
        repeat(1) @(negedge clk);
        w_data = 8'd1;                                //in address = 7
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;                                    //------------------------------ Full
        
        // write
        repeat(1) @(negedge clk);
        w_data = 8'd3;
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;        
        
        // ----------------FULL-----------------------
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // read
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;
        
        // ----------------EMPTY-----------------------
        
        // read & write at the same time
        repeat(1) @(negedge clk);
        w_data = 8'd7;
        wr = 1'b1;
        rd = 1'b1;
        @(negedge clk)
        wr = 1'b0;
        rd = 1'b0;
        
        // read while empty
        repeat(1) @(negedge clk);
        rd = 1'b1;
        @(negedge clk)
        rd = 1'b0;

        // ----------------NOT EMPTY-----------------------
        repeat(1) @(negedge clk);
        w_data = 16'h11ff;
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;
        
        repeat(1) @(negedge clk);
        w_data = 16'hcc22;
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;
        
        repeat(1) @(negedge clk);
        w_data = 16'hb1c1;
        wr = 1'b1;
        @(negedge clk)
        wr = 1'b0;
        
        // read & write at the same time
        repeat(1) @(negedge clk);
        w_data = 16'h8899;
        wr = 1'b1;
        rd = 1'b1;
        @(negedge clk)
        wr = 1'b0;
        rd = 1'b0;
        
        repeat(3) @(negedge clk);
        $stop;
                
        
    end
    
endmodule

