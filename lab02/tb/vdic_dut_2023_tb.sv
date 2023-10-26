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

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
module top;

//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// Local variables
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
	


test_result_t               test_result     = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .arg_parity_error, .result_rdy);

//------------------------------------------------------------------------------
// Coverage block
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

dut_cov                     oc;
zeros_or_ones_on_ops        c_00_FF;

initial begin : coverage

    oc      = new();
    c_00_FF = new();
    forever begin : sample_cov
        @(posedge clk);
            oc.sample();
            c_00_FF.sample();
            
            /* #1step delay is necessary before checking for the coverage
             * as the .sample methods run in parallel threads
             */
            #1step; 
            if($get_coverage() == 100) break; //disable, if needed
            
            // you can print the coverage after each sample
//            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    end
end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

function bit arg_parity_flag(
	logic signed [15:0] arg,
	logic arg_parity );
	bit flag;
	
	if( arg_parity === ^arg)
		flag=1'b0;
	else 
		flag=1'b1;
endfunction :arg_parity_flag
		
	
//---------------------------------
// Random data generation functions

//---------------------------------
function logic signed [15:0] get_data();

    bit [2:0] zero_ones;
    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'sh8000; 
    else if (zero_ones == 3'b111)
        return 16'sh7FFF;  
    else
        return 16'($random);
endfunction : get_data



function logic [1:0] get_parity(
	logic signed [15:0] arg_a,
	logic signed [15:0] arg_b
	);
    bit zero_ones;
	bit zero_ones_2;
	bit counter;
	logic arg_a_parity;
	logic arg_b_parity;
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
    return {arg_a_parity,arg_b_parity}; 
   
endfunction : get_parity
//------------------------
// Tester main


initial begin : tester
	logic signed [31:0] expected;   
	logic expected_arg_parity_error;
	reset();
	rst_n=1'b0;
	#5;
	rst_n=1'b1;
    repeat (1000) begin : tester_main_blk
        @(negedge clk)
        //valid arg_a valid arg_b valid arg_a_parity valid arg_b_parity
        	arg_a = get_data();
        	arg_b = get_data();
        	req   = 1'b1;
	    	{arg_a_parity, arg_b_parity }= get_parity(arg_a, arg_b); 
	    	wait(ack); //wait for high ack to move to next steps
	    	req = 0;
	    	wait(result_rdy);
	    	{expected, expected_arg_parity_error} = get_expected(arg_a, arg_b, arg_a_parity, arg_b_parity);
        	if(result === expected && result_parity ===^expected && arg_parity_error===expected_arg_parity_error) begin
        		`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
               	$display("1 Expected : %d  received: %d", expected, result);
	        	`endif
                test_result = TEST_FAILED;
            end
        @(negedge clk)
            req   = 1'b1;
            arg_a = 16'sh8000;
        	arg_b = 16'sh8000;
	    	arg_a_parity = ^arg_a; 
	    	arg_b_parity = ^arg_b;
	    	wait(ack); //wait for high ack to move to next steps
	    	req = 0;
	    	wait(result_rdy);
	    	{expected, expected_arg_parity_error} = get_expected(arg_a, arg_b, arg_a_parity, arg_b_parity);
        	if(result === expected && result_parity ===^expected && arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
               	$display("7 Expected : %d  received: %d", expected, result);
	        	`endif
                test_result = TEST_FAILED;
            end
            //reset();
        @(negedge clk)
            // tests for marginal values from range 16'sh7FFF
            arg_a = 16'sh7FFF;
        	arg_b = 16'sh7FFF;
        	req   = 1'b1;
	    	arg_a_parity = ^arg_a; 
	    	arg_b_parity = ^arg_b;
	    	wait(ack); //wait for high ack to move to next steps
	    	req = 0;
	    	wait(result_rdy);
        	{expected, expected_arg_parity_error} = get_expected(arg_a, arg_b, arg_a_parity, arg_b_parity);
        	if(result === expected && result_parity ===^expected && arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
               	$display("8 Expected : %d  received: %d", expected, result);
	        	`endif
                test_result = TEST_FAILED;
        	end
        @(negedge clk)
            arg_a = 16'sh8000;
        	arg_b = 16'sh7FFF;
        	req   = 1'b1;
	    	arg_a_parity = ^arg_a; 
	    	arg_b_parity = ^arg_b;
	    	wait(ack); //wait for high ack to move to next steps
	    	req = 0;
	    	wait(result_rdy);
        	{expected, expected_arg_parity_error} = get_expected(arg_a, arg_b, arg_a_parity, arg_b_parity);
        	if(result === expected && result_parity ===^expected && arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
               	$display("8 Expected : %d  received: %d", expected, result);
	        	`endif
                test_result = TEST_FAILED;
            end
        @(negedge clk)
            arg_a = 16'sh7FFF;
        	arg_b = 16'sh8000;
        	req   = 1'b1;
	    	arg_a_parity = ^arg_a; 
	    	arg_b_parity = ^arg_b;
	    	wait(ack); //wait for high ack to move to next steps
	    	req = 0;
	    	wait(result_rdy);
        	{expected, expected_arg_parity_error} = get_expected(arg_a, arg_b, arg_a_parity, arg_b_parity);
        	if(result === expected && result_parity ===^expected && arg_parity_error===expected_arg_parity_error) begin
	        	`ifdef DEBUG
        		$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
	        	`endif
            end
        	else begin
	        	`ifdef DEBUG
            	$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
               	$display("8 Expected : %d  received: %d", expected, result);
	        	`endif
                test_result = TEST_FAILED;
            end
    end
    $finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
task reset();
    req     = 1'b0;
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
endtask : reset

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function logic signed [32:0] get_expected(
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
// Temporary. The scoreboard will be later used for checking the data
final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

function void print_test_result (test_result_t r);
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
// Scoreboard
//------------------------------------------------------------------------------
logic                         start_prev;
typedef struct packed {
    logic signed [15:0]  arg_a;
    logic signed [15:0]  arg_b;
	logic 				 arg_a_parity;
	logic  				 arg_b_parity;
	logic signed [31:0]  result;
	logic 				 arg_parity_error;
	//logic 				 result_parity;
	
} data_packet_t;

data_packet_t               sb_data_q   [$];

always @(posedge clk) begin:scoreboard_fe_blk
    if(req == 1 && start_prev == 0) begin
                sb_data_q.push_front(
                    data_packet_t'({
	                    arg_a,
	                    arg_b,
	                    arg_a_parity,
	                    arg_b_parity,
	                    get_expected(arg_a, arg_b, arg_a_parity, arg_b_parity)})
                );
            //end
    end
    start_prev = req;
end


always @(negedge clk) begin : scoreboard_be_blk
    if(result_rdy) begin:verify_result
        data_packet_t dp;

        dp = sb_data_q.pop_back();

        CHK_RESULT: assert(result === dp.result && arg_parity_error === dp.arg_parity_error) begin
           `ifdef DEBUG
            $display("%0t Test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
           `endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("%0t Test FAILED for arg_a=%0d arg_b=%0d \n Expected: %d  received: %d",
                $time, dp.arg_a, dp.arg_b, dp.result, result);
        end;

    end
end : scoreboard_be_blk

endmodule : top
