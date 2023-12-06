class scoreboard extends uvm_subscriber #(result_s);
    `uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// Local type definitions
//------------------------------------------------------------------------------
	protected typedef enum bit {
	    TEST_PASSED,
	    TEST_FAILED
	} test_result_t;
	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    uvm_tlm_analysis_fifo #(command_s) cmd_f;
    protected test_result_t test_result = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
	protected function void print_test_result (test_result_t r);
	    if(r == TEST_PASSED) begin
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
// Calculate expected result
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



    function void write(result_s t);
	    
        logic signed [31:0] predicted_result;
		logic arg_parity_error;
	     

        command_s cmd;
	    cmd.rst_n = 0;
        cmd.arg_a = 0;
        cmd.arg_b = 0;
	    cmd.arg_a_parity = 0;
	    cmd.arg_b_parity = 0;
	    //cmd.flag_arg_a_parity;
	    //cmd.flag_arg_b_parity;
	    
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.rst_n == 0);	// get commands until rst_n == 0

        {predicted_result, arg_parity_error} = get_expected(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
			assert(t.result === predicted_result ) begin
				`ifdef DEBUG
				$display("TEST PASSED: %0t Test passed for A=%0d B=%0d", $time, cmd.arg_a, cmd.arg_b);
				`endif
			end
			else begin
				test_result = TEST_FAILED;
				$error("TEST FAILED for result: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d", $time, cmd.arg_a, cmd.arg_b, predicted_result, t.result);
			end
			assert(t.arg_parity_error === arg_parity_error ) begin
				`ifdef DEBUG
				$display("TEST PASSED: %0t Test passed for A=%0d B=%0d", $time, cmd.arg_a, cmd.arg_b);
				`endif
			end
			else begin
				test_result = TEST_FAILED;
				$error("TEST FAILED for result parity: %0t Test FAILED for A=%0d B=%0d\n Parity expected: %d  received: %d", $time, cmd.arg_a, cmd.arg_b, arg_parity_error, t.arg_parity_error);
			end
	endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(test_result);
    endfunction : report_phase

	
endclass : scoreboard