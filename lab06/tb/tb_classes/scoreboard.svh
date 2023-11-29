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
class scoreboard extends uvm_subscriber #(command_s);
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------
    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
//    virtual tinyalu_bfm bfm;
    uvm_tlm_analysis_fifo #(command_s) cmd_f;

    protected test_result tr = TEST_PASSED; // the result of the current test
	
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result r);
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
// function to calculate the expected ALU result
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
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase


//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(command_s t);
        logic signed [31:0] predicted_result;
	    logic  				arg_parity_error;
        command_s cmd;
        cmd.arg_a            = 0;
        cmd.arg_b            = 0;
        cmd.arg_a_parity     = 0;
	    cmd.arg_b_parity	 = 0;
	    cmd.rst_n			 = 0;
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while ( cmd.rst_n == 0 );

        {predicted_result, arg_parity_error} = get_expected(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);

        SCOREBOARD_CHECK:
        assert (predicted_result == t.result && arg_parity_error == ^t.result) begin
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d", $time, cmd.arg_a, cmd.arg_b);
            `endif
        end
        else begin
            $error("FAILED: A: %0h  B: %0h  result: %0h  predicted result: %0h", cmd.arg_a, cmd.arg_b, t, predicted_result);
            tr = TEST_FAILED;
        end
    endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard






