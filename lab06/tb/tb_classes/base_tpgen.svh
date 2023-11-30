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
virtual class base_tpgen extends uvm_component;

// base tpgen instance is never created, so we do not need macros
//     `uvm_component_utils(base_tpgen)

//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;

//------------------------------------------------------------------------------
//  function prototypes
//------------------------------------------------------------------------------
    //pure virtual protected function operation_t get_op();
    pure virtual protected function logic signed [15:0] get_data();


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
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

        command_s command;

        phase.raise_objection(this);
        command.rst_n = 1;
        command_port.put(command);
	    command.rst_n = 0;
        repeat (10000) begin : random_loop
	        
            command.arg_a  = get_data();
            command.arg_b  = get_data();
	        {command.arg_a_parity, command.arg_b_parity, command.flag_arg_a_parity, command.flag_arg_b_parity }= get_parity(command.arg_a, command.arg_b);
	        //command.op = get_op();
            command_port.put(command);
        end : random_loop
        #500;
        //command.rst_n = 1;
        command_port.put(command);
        command_port.put(command);
        phase.drop_objection(this);
    endtask : run_phase


endclass : base_tpgen
