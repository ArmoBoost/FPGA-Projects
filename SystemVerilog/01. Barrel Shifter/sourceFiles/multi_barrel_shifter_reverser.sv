`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////


module multi_barrel_shifter_reverser
    #(parameter N = 3)
    (
    input logic [(2**N)-1:0] a,
    input logic [N-1:0] amt,
    input logic lr, 
    output logic [(2**N)-1:0] y
    );

    logic [(2**N)-1:0] y_right, y_left, y_rev, y_rev2, mux1_output;
    
    reverser #(.N(N)) reverse1( //first reverse block from input
        .org(a),
        .rev(y_rev)
    );
    
    //----------------------- first Mux
    always_comb begin
        mux1_output = lr ? a : y_rev; 
    end
    
    
    param_right_shifter #(.N(N)) rotate_right( //gets reversed value from previous block and puts value into right shifter
        .a(mux1_output),
        .amt(amt),
        .y(y_right)
    );
    
   
    reverser #(.N(N)) reverse2(//gets value from the right shifter and reverses the bits again. y_left stores the left shift value
        .org(y_rev2),
        .rev(y_left)
    );   
    
     //----------------------- Second Mux
    always_comb begin
        y = lr ? y_right : y_left; 
    end


endmodule









