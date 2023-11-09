/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module tpgen(mult_bfm bfm);
    
//import mult_pkg::*;


function logic signed [15:0] get_data();

    bit [2:0] zero_ones;
    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'sh8000; 
    else if (zero_ones == 3'b111)
        return 16'sh7FFF;  
    else
        return 16'($random);
endfunction : get_data


/*
initial begin : tester
	logic signed [15:0] iarg_a;
	logic iarg_a_parity;
	logic signed [15:0] iarg_b;
	logic iarg_b_parity;
	logic signed [31:0] expected;   
	logic expected_arg_parity_error;
	logic rst_n;
	
	bfm.reset();
	rst_n=1'b0;
	#5;
	rst_n=1'b1;
    repeat (1000) begin : tester_main_blk
        @(negedge bfm.clk)
        //valid arg_a valid arg_b valid arg_a_parity valid arg_b_parity
        	iarg_a = get_data();
        	iarg_b = get_data();
        	bfm.req   = 1'b1;
	    	{iarg_a_parity, iarg_b_parity }= get_parity(iarg_a, iarg_b); 
	    	wait(bfm.ack); //wait for high ack to move to next steps
	    	bfm.req = 0;
	    	wait(bfm.result_rdy);
	    	{expected, expected_arg_parity_error} = get_expected(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity);
        	if(bfm.result === expected && bfm.result_parity ===^expected && bfm.arg_parity_error===expected_arg_parity_error) begin
        		`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", bfm.arg_a, bfm.arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", bfm.arg_a, bfm.arg_b);
               	$display("1 Expected : %d  received: %d", expected, result);
	        	`endif
                bfm.tr = TEST_FAILED;
            end
        @(negedge bfm.clk)
            bfm.req   = 1'b1;
            iarg_a = 16'sh8000;
        	iarg_b = 16'sh8000;
	    	iarg_a_parity = ^iarg_a; 
	    	iarg_b_parity = ^iarg_b;
	    	wait(bfm.ack); //wait for high ack to move to next steps
	    	bfm.req = 0;
	    	wait(bfm.result_rdy);
	    	{expected, expected_arg_parity_error} = get_expected(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity);
        	if(bfm.result === expected && bfm.result_parity ===^expected && bfm.arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", bfm.arg_a, bfm.arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", bfm.arg_a, bfm.arg_b);
               	$display("7 Expected : %d  received: %d", expected, result);
	        	`endif
                bfm.tr = TEST_FAILED;
            end
            //reset();
        @(negedge bfm.clk)
            // tests for marginal values from range 16'sh7FFF
            iarg_a = 16'sh7FFF;
        	iarg_b = 16'sh7FFF;
        	bfm.req   = 1'b1;
	    	iarg_a_parity = ^iarg_a; 
	    	iarg_b_parity = ^iarg_b;
	    	wait(bfm.ack); //wait for high ack to move to next steps
	    	bfm.req = 0;
	    	wait(bfm.result_rdy);
        	{expected, expected_arg_parity_error} = get_expected(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity);
        	if(bfm.result === expected && bfm.result_parity ===^expected && bfm.arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", iarg_a, iarg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", iarg_a, iarg_b);
               	$display("8 Expected : %d  received: %d", expected, result);
	        	`endif
                bfm.tr = TEST_FAILED;
        	end
        @(negedge bfm.clk)
            iarg_a = 16'sh8000;
        	iarg_b = 16'sh7FFF;
        	bfm.req   = 1'b1;
	    	iarg_a_parity = ^iarg_a; 
	    	iarg_b_parity = ^iarg_b;
	    	wait(bfm.ack); //wait for high ack to move to next steps
	    	bfm.req = 0;
	    	wait(bfm.result_rdy);
        	{expected, expected_arg_parity_error} = get_expected(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity);
        	if(bfm.result === expected && bfm.result_parity ===^expected && bfm.arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", iarg_a, iarg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", iarg_a, iarg_b);
               	$display("8 Expected : %d  received: %d", expected, result);
	        	`endif
                bfm.tr = TEST_FAILED;
            end
        @(negedge bfm.clk)
            iarg_a = 16'sh7FFF;
        	iarg_b = 16'sh8000;
        	bfm.req   = 1'b1;
	    	iarg_a_parity = ^iarg_a; 
	    	iarg_b_parity = ^iarg_b;
	    	wait(bfm.ack); //wait for high ack to move to next steps
	    	bfm.req = 0;
	    	wait(bfm.result_rdy);
        	{expected, expected_arg_parity_error} = get_expected(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity);
        	if(bfm.result === expected && bfm.result_parity ===^expected && bfm.arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", iarg_a, iarg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", iarg_a, iarg_b);
               	$display("8 Expected : %d  received: %d", expected, result);
	        	`endif
                bfm.tr = TEST_FAILED;
            end
    end
    $finish;
end : tester

*/

function logic [3:0] get_parity(
	logic signed [15:0] arg_a,
	logic signed [15:0] arg_b
	);
    bit zero_ones;
	bit zero_ones_2;
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

initial begin
	logic signed 	[15:0] 	iA;
	logic               	iA_parity;
	logic signed 	[15:0] 	iB;        
	logic               	iB_parity;
	logic 					flag_arg_a_parity;
	logic 					flag_arg_b_parity;
	
	logic signed 	[31:0] 	result;
	logic               	result_parity;
    
   
    bfm.reset();
    repeat (1000) begin : random_loop
        iA = get_data();
        iB = get_data();
	    {iA_parity, iB_parity, flag_arg_a_parity, flag_arg_b_parity }= get_parity(iA, iB); 
        bfm.send_data(iA, iA_parity, iB, iB_parity, flag_arg_a_parity, flag_arg_b_parity);
	    //wait(bfm.result_rdy);
    end : random_loop
    bfm.send_data(iA, iA_parity, iB, iB_parity, flag_arg_a_parity, flag_arg_b_parity);
	bfm.reset();
    
    $finish;
    
end // initial begin
	

endmodule : tpgen
