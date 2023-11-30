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

//------------------------------------------------------------------------------
// the interface
//------------------------------------------------------------------------------

interface mult_bfm;

//------------------------------------------------------------------------------
// dut connections
//------------------------------------------------------------------------------

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

    

command_monitor command_monitor_h;
result_monitor result_monitor_h;
    
//------------------------------------------------------------------------------
// DUT reset task
//------------------------------------------------------------------------------


initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end


task reset();
    req     = 1'b0;
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
endtask : reset

//------------------------------------------------------------------------------
// send transaction to DUT
//------------------------------------------------------------------------------


task send_data(
	input logic signed 	[15:0] 	iA,
	input logic               	iA_parity,
	input logic signed 	[15:0] 	iB,
	input logic               	iB_parity,
	bit flag_arg_a_parity_tpgen,
	bit flag_arg_b_parity_tpgen,
	logic signed [31:0] result
	);

    arg_a = iA;
    arg_b = iB;
	arg_a_parity = iA_parity;
	arg_b_parity = iB_parity;
	flag_arg_a_parity = flag_arg_a_parity_tpgen;
	flag_arg_b_parity = flag_arg_b_parity_tpgen;

	@(posedge clk); //!!!
    req = 1'b1;    
	wait(ack);	
	req = 1'b0;
	wait(result_rdy);

endtask : send_data



//------------------------------------------------------------------------------
// convert binary op code to enum
//------------------------------------------------------------------------------
/*
function operation_t op2enum();
    operation_t opi;
    if( ! $cast(opi,op) )
        $fatal(1, "Illegal operation on op bus");
    return opi;
endfunction : op2enum
*/
//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------

always @(posedge clk) begin : op_monitor
    //static bit in_command = 0;
    command_s command;
    //if (start) begin : start_high
    if (req) begin : start_high
            command.arg_a  = arg_a;
            command.arg_b  = arg_b;
	        command.arg_a_parity = arg_a_parity; //czy to dopisac??
	    	command.arg_b_parity = arg_b_parity;
	        command.rst_n = rst_n;
            command_monitor_h.write_to_monitor(command);
            //in_command = (command.op != no_op);
    end : start_high
    //end : start_high
    //else // start low
        //in_command = 0;
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    command_s command;
    command.rst_n = 0;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor


//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

initial begin : result_monitor_thread
	command_s command;
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
	       	command.result = result;
    		command.flag_arg_a_parity = flag_arg_a_parity;
	    	command.flag_arg_b_parity = flag_arg_b_parity;
    		command.arg_a_parity = arg_a_parity; //czy to dopisac??
	    	command.arg_b_parity = arg_b_parity;
            result_monitor_h.write_to_monitor(command);
	    end
    end
end : result_monitor_thread

//------------------------------------------------------------------------------
// clock generator
//------------------------------------------------------------------------------




endinterface : mult_bfm
