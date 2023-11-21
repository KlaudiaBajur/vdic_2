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

// The macro is not there as we never instantiate/use the base_tpgen
//    `uvm_component_utils(base_tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function logic signed [15:0] get_data();
    pure virtual protected function logic [3:0] get_parity(logic signed [15:0] arg_a, logic signed [15:0] arg_b );

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        logic signed 	[15:0] 	iA;
		logic               	iA_parity;
		logic signed 	[15:0] 	iB;        
		logic               	iB_parity;
		logic 					flag_arg_a_parity;
		logic 					flag_arg_b_parity;
	
		logic signed 	[31:0] 	result;
		logic               	result_parity;

        phase.raise_objection(this);

        bfm.reset();

        repeat (1000) begin : random_loop
            iA = get_data();
        	iB = get_data();
	    	{iA_parity, iB_parity, flag_arg_a_parity, flag_arg_b_parity }= get_parity(iA, iB); 
        	bfm.send_data(iA, iA_parity, iB, iB_parity, flag_arg_a_parity, flag_arg_b_parity);
	    	//wait(bfm.result_rsdy);
        end : random_loop
        //bfm.send_data(iA, iA_parity, iB, iB_parity, flag_arg_a_parity, flag_arg_b_parity);
		bfm.reset();
//      #500;

        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tpgen
