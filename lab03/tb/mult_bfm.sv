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
interface mult_bfm;
//import mult_pkg::*;

logic clk;
logic               rst_n;
logic signed [15:0] arg_a;
logic arg_a_parity;
logic signed [15:0] arg_b;
logic arg_b_parity;
logic req;

logic ack;
logic signed [31:0] result;
logic result_parity;
logic arg_parity_error;
logic result_rdy;
	
bit flag_arg_a_parity;
bit flag_arg_b_parity;


//modport tlm (import rst_n);
    
//------------------------------------------------------------------------------
// clock generator  
//------------------------------------------------------------------------------
initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end


//------------------------------------------------------------------------------
// reset
//------------------------------------------------------------------------------

task reset();
    req     = 1'b0;
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
endtask : reset



task send_data(
	input logic signed 	[15:0] 	iA,
	input logic               	iA_parity,
	input logic signed 	[15:0] 	iB,
	input logic               	iB_parity
	//bit flag_arg_a_parity_tpgen,
	//bit flag_arg_b_parity_tpgen
	);

    arg_a = iA;
    arg_b = iB;
	arg_a_parity = iA_parity;
	arg_b_parity = iB_parity;
	//flag_arg_a_parity = flag_arg_a_parity_tpgen;
	//flag_arg_a_parity = flag_arg_a_parity_tpgen;

    req = 1'b1;    
	wait(ack);	
	req = 1'b0;
	wait(result_rdy);

endtask : send_data


endinterface : mult_bfm


