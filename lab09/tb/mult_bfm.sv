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
import mult_pkg::*;
interface mult_bfm;

//------------------------------------------------------------------------------
// dut connections
//------------------------------------------------------------------------------

bit               		clk;
bit 					rst_n;
logic signed 	[15:0] 	arg_a;
bit               		arg_a_parity;
bit               		flag_arg_a_parity;
logic signed 	[15:0] 	arg_b;      
bit               		arg_b_parity;
bit               		flag_arg_b_parity;
bit               		req;
	
logic               	ack;
logic signed 	[31:0] 	result;
logic               	result_parity;
logic               	result_rdy;
logic               	arg_parity_error; 


command_monitor command_monitor_h;
result_monitor result_monitor_h;
	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end


task reset_alu();
	req = 1'b0;
	rst_n = 1'b0;
	@(negedge clk);
	rst_n = 1'b1;
endtask : reset_alu

//------------------------------------------------------------------------------
// send transaction to DUT
//------------------------------------------------------------------------------

task send_data(
	input bit					irst,
	input logic signed 	[15:0] 	iA,
	input logic               	iA_parity,
	input logic signed 	[15:0] 	iB,
	input logic               	iB_parity,
	bit flag_arg_a_parity_tpgen,
	bit flag_arg_b_parity_tpgen
	);

    
	if(irst) begin
		reset_alu();
	end
	else begin
	    arg_a = iA;
	    arg_b = iB;
		arg_a_parity = iA_parity;
		arg_b_parity = iB_parity;
		flag_arg_a_parity = flag_arg_a_parity_tpgen;
		flag_arg_b_parity = flag_arg_b_parity_tpgen;
        
	    req = 1'b1;
		wait(ack);	
		req = 1'b0;
		wait(result_rdy);
		rst_n = 1'b1;
	end
endtask : send_data

//------------------------------------------------------------------------------
// convert binary op code to enum
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
always @(posedge clk) begin
    if (req) begin
        command_monitor_h.write_to_monitor(rst_n, arg_a, arg_b, arg_a_parity, arg_b_parity, flag_arg_a_parity, flag_arg_b_parity);
    end
end

always @(negedge rst_n) begin : rst_monitor
    if (command_monitor_h != null) 
        command_monitor_h.write_to_monitor(0, arg_a, arg_b, arg_a_parity, arg_b_parity, flag_arg_a_parity, flag_arg_b_parity);
end : rst_monitor

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------
initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
            result_monitor_h.write_to_monitor(result, result_parity, arg_parity_error);
	    end
    end
end : result_monitor_thread



endinterface : mult_bfm
