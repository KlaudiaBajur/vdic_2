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
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
    protected typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;


	protected logic start_prev;
	
	
    protected typedef struct packed {
    	logic signed [15:0]  arg_a;
    	logic signed [15:0]  arg_b;
		logic 				 arg_a_parity;
		logic  				 arg_b_parity;
		logic signed [31:0]  result;
		logic 				 arg_parity_error;
		//logic 				 result_parity;
	
    } data_packet_t;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    protected test_result tr = TEST_PASSED; // the result of the current test

    // fifo for storing input and expected data
    protected data_packet_t sb_data_q [$];

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


	
//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------


    protected function logic signed [32:0] get_expected(
		logic signed [15:0] arg_a,
		logic signed [15:0] arg_b,
		logic  				arg_a_parity,
		logic  				arg_b_parity
		);
		logic  				arg_parity_error;
		logic  				result_parity;
		logic signed [31:0] ret;

		ret= arg_a*arg_b;
	
		if(arg_a_parity != ^arg_a || arg_b_parity != ^arg_b  || result_parity != ^ret) begin
			arg_parity_error = 1'b1;
			ret = 0;
		end
		else begin
			arg_parity_error = 0;
		end
		return{ret, arg_parity_error};
	endfunction : get_expected

	
//------------------------------------------------------------------------------
// local tasks
//------------------------------------------------------------------------------
    protected task store_cmd();
		forever begin:scoreboard_fe_blk
			@(posedge bfm.clk) begin:scoreboard_fe_blk
    			if(bfm.req == 1 && start_prev == 0) begin
                	sb_data_q.push_front(
                    data_packet_t'({
	                    bfm.arg_a, // call the task
	                    bfm.arg_b,
	                    bfm.arg_a_parity,
	                    bfm.arg_b_parity,
	                    get_expected(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity)})
                	);
            	end
    		end
    		start_prev = bfm.req;
		end
    endtask
    
    
    
    
    protected task process_data_from_dut();
    	forever begin : scoreboard_be_blk
			@(negedge bfm.clk)
    			if(bfm.result_rdy) begin:verify_result
        			data_packet_t dp;

        			dp = sb_data_q.pop_back();

        			CHK_RESULT: assert(bfm.result === dp.result && bfm.arg_parity_error === dp.arg_parity_error) begin
           			`ifdef DEBUG
       				     $display("%0t Test passed for arg_a=%0d arg_b=%0d Expected: %d  received: %d", $time, dp.arg_a, dp.arg_b, dp.result, bfm.result );
           			`endif
        			end
        			else begin
            		tr = TEST_FAILED;
            		$error("%0t Test FAILED for arg_a=%0d arg_b=%0d \n Expected: %d  received: %d", $time, dp.arg_a, dp.arg_b, dp.result, bfm.result );
        			end
        		end
        		
    	end : scoreboard_be_blk
	endtask

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
	    //phase.raise_objection(this); /// nope
	    //add_tpgen_h = new(bfm);
	    //coverage_h = new(bfm);
	    //scoreboard_h = new(bfm);
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    //phase.drop_objection(this); /// here?
    endtask : run_phase

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result tr);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard