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
class coverage extends uvm_component;
    `uvm_component_utils(coverage)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;

    protected logic signed [15:0] arg_a;
    protected logic signed [15:0] arg_b;
    protected bit flag_arg_a_parity;
	protected bit flag_arg_b_parity;

//------------------------------------------------------------------------------
// covergroups
//------------------------------------------------------------------------------
// Covergroup checking the op codes and theri sequences
covergroup dut_cov;

    option.name = "cg_dut_cov";
	//Test 1, 2, 3, 4 from specification
	coverpoint flag_arg_a_parity {
			bins arg_parity_error_flag = {1'b1};
	    	bins arg_parity_error_no_flag = {1'b0};
		
	}
	
	coverpoint flag_arg_b_parity {
			bins arg_parity_error_flag = {1'b1};
	        bins arg_parity_error_no_flag = {1'b0};
		
	}

	parity_cross: cross flag_arg_a_parity, flag_arg_b_parity {
	bins  no_error 	= binsof (flag_arg_a_parity.arg_parity_error_no_flag) 	&& binsof (flag_arg_b_parity.arg_parity_error_no_flag);
	bins  error_a  	= binsof (flag_arg_a_parity.arg_parity_error_flag) 		&& binsof (flag_arg_b_parity.arg_parity_error_no_flag);
	bins  error_b  	= binsof (flag_arg_a_parity.arg_parity_error_no_flag) 	&& binsof (flag_arg_b_parity.arg_parity_error_flag);
	bins  error_a_b = binsof (flag_arg_a_parity.arg_parity_error_flag) 		&& binsof (flag_arg_b_parity.arg_parity_error_flag);

	}
endgroup

// Covergroup checking for min and max arguments 
covergroup zeros_or_ones_on_ops;

    option.name = "cg_zeros_or_ones_on_ops";

    a_leg: coverpoint arg_a {
        bins zeros = {16'sh8000};
        bins others= {[16'sh8001:16'sh7FFE]};
        bins ones  = {16'sh7FFF};
    }

    b_leg: coverpoint arg_b {
        bins zeros = {16'sh8000};
        bins others= {[16'sh8001:16'sh7FFE]};
        bins ones  = {16'sh7FFF};
    }
    

    B_00_FF: cross a_leg, b_leg {
	    
	    bins zeros_cross 		= binsof (a_leg.zeros) 	&& binsof (b_leg.zeros);
	    bins ones_cross 		= binsof (a_leg.ones) 	&& binsof (b_leg.ones);
	    bins zeros_ones_cross   = binsof (a_leg.zeros)  && binsof (b_leg.ones);
	    bins ones_zeros_cross   = binsof (a_leg.ones) 	&& binsof (b_leg.zeros);
    }
    

endgroup
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        dut_cov              = new();
        zeros_or_ones_on_ops = new();
    endfunction : new

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
        forever begin : sampling_block
            @(posedge bfm.clk);
            arg_a      = bfm.arg_a;
            arg_b      = bfm.arg_b;
            flag_arg_a_parity = bfm.flag_arg_a_parity;
	    	flag_arg_b_parity = bfm.flag_arg_b_parity;
            dut_cov.sample();
            zeros_or_ones_on_ops.sample();
	        #1; 
            if($get_coverage() == 100) break; //disable, if needed
        end : sampling_block
    endtask : run_phase


endclass : coverage






