module mult_tpgen_module(mult_bfm bfm);
import mult_pkg::*;

//---------------------------------
// Random data generation functions
//---------------------------------
function logic signed [15:0] get_data();
    bit zero_ones;
    zero_ones = 1'($random);

    if (zero_ones == 1'b0)
        return 16'sh8000;		
    else 	
        return 16'sh7FFF;	
    
endfunction : get_data


function logic [3:0] get_parity(
		logic signed [15:0] arg_a,
		logic signed [15:0] arg_b
		);
    	bit  zero_ones;
		bit  zero_ones_2;
		bit counter;
		logic arg_a_parity;
		logic arg_b_parity;
		bit flag_arg_a_parity;
		bit flag_arg_b_parity;

    	zero_ones = 1'($random);
		zero_ones_2 = 1'($random);
	
    	if (zero_ones == 1'b1)begin
	    	arg_a_parity=~^arg_a;
    		flag_arg_a_parity =1'b1;
		end
    	else if (zero_ones == 1'b0) begin
        	arg_a_parity=^arg_a;
	    	flag_arg_a_parity=1'b0;
		end
    	if (zero_ones_2 == 1'b1) begin
	    	arg_b_parity=~^arg_a;
    		flag_arg_b_parity =1'b1;
		end
    	else if (zero_ones_2 == 1'b0) begin
        	arg_b_parity=^arg_b;
	    	flag_arg_b_parity=1'b0;
    	end
    	return {arg_a_parity,arg_b_parity,flag_arg_a_parity,flag_arg_b_parity}; 
   
endfunction : get_parity
	
//------------------------------------------------------------------------------
/*
initial begin
	bit						irst;
	logic signed 	[15:0] 	iA;
	logic               	iA_parity;
	logic signed 	[15:0] 	iB;        
	logic               	iB_parity;
	bit flag_arg_a_parity_tpgen;
	bit flag_arg_b_parity_tpgen;
	logic signed 	[31:0] 	result;
	logic               	result_parity;

    bfm.reset_mult();
    repeat (1000) begin : random_loop
        iA = get_data();
        iB = get_data();
	    {iA_parity, iB_parity, flag_arg_a_parity_tpgen, flag_arg_b_parity_tpgen} = get_parity(iA, iB);
        bfm.send_data(irst, iA, iA_parity, iB, iB_parity, flag_arg_a_parity_tpgen, flag_arg_b_parity_tpgen);
	    bfm.wait_ready();	// wait until result is ready
    end : random_loop
    
    // reset until DUT finish processing data
    bfm.send_data(irst, iA, iA_parity, iB, iB_parity, flag_arg_a_parity_tpgen, flag_arg_b_parity_tpgen);
    bfm.reset_mult();
end // initial begin
*/


initial begin
		bit						irst;
		logic signed 	[15:0] 	iA;
		logic               	iA_parity;
		logic signed 	[15:0] 	iB;        
		logic               	iB_parity;
		logic 					flag_arg_a_parity;
		logic 					flag_arg_b_parity;
	
		logic signed 	[31:0] 	result;
		logic               	result_parity;
    
   
    	bfm.reset_mult();
    	repeat (1000) begin : random_loop
        	iA = get_data();
        	iB = get_data();
	    	{iA_parity, iB_parity, flag_arg_a_parity, flag_arg_b_parity }= get_parity(iA, iB); 
        	bfm.send_data(irst, iA, iA_parity, iB, iB_parity, flag_arg_a_parity, flag_arg_b_parity);
	    	//wait(bfm.result_rdy);
    	end : random_loop
    	//bfm.send_data(iA, iA_parity, iB, iB_parity, flag_arg_a_parity, flag_arg_b_parity);
		bfm.reset_mult();
    
    	
    	//tu nie powinno byc finish
end 


endmodule : mult_tpgen_module