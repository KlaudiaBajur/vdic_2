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
class tpgen;

    protected virtual mult_bfm bfm;

    function new (virtual mult_bfm b);
        bfm = b;
    endfunction : new


	protected function logic signed [15:0] get_data();

    	bit [2:0] zero_ones;
    	zero_ones = 3'($random);

    	if (zero_ones == 3'b000)
        	return 16'sh8000; 
    	else if (zero_ones == 3'b111)
        	return 16'sh7FFF;  
    	else
        	return 16'($random);
	endfunction : get_data



	protected function logic [3:0] get_parity(
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



	task execute();
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
    
    	
    	//tu nie powinno byc finish
	endtask : execute // initial begin





endclass : tpgen






