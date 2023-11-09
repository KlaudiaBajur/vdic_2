module scoreboard(mult_bfm bfm);
	
//------------------------------------------------------------------------------
// Local type definitions
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
test_result_t        test_result = TEST_PASSED;
	
//------------------------------------------------------------------------------
// Calculate expected result
//------------------------------------------------------------------------------
//bit flag_arg_a_parity;
//bit flag_arg_b_parity;
	
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
// Scoreboard
//------------------------------------------------------------------------------
logic start_prev;


typedef struct packed {
    logic signed [15:0]  arg_a;
    logic signed [15:0]  arg_b;
	logic 				 arg_a_parity;
	logic  				 arg_b_parity;
	logic signed [31:0]  result;
	logic 				 arg_parity_error;
	//logic 				 result_parity;
	
} data_packet_t;

data_packet_t sb_data_q [$];



always @(posedge bfm.clk) begin:scoreboard_fe_blk
    if(bfm.req == 1 && start_prev == 0) begin
                sb_data_q.push_front(
                    data_packet_t'({
	                    bfm.arg_a,
	                    bfm.arg_b,
	                    bfm.arg_a_parity,
	                    bfm.arg_b_parity,
	                    get_expected(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity)})
                );
            //end
    end
    start_prev = bfm.req;
end



always @(negedge bfm.clk) begin : scoreboard_be_blk
    if(bfm.result_rdy) begin:verify_result
        data_packet_t dp;

        dp = sb_data_q.pop_back();

        CHK_RESULT: assert(bfm.result === dp.result && bfm.arg_parity_error === dp.arg_parity_error) begin
           `ifdef DEBUG
       //     $display("%0t Test passed for arg_a=%0d arg_b=%0d Expected: %d  received: %d", $time, dp.arg_a, dp.arg_b, dp.result, bfm.result );
           `endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("%0t Test FAILED for arg_a=%0d arg_b=%0d \n Expected: %d  received: %d",
                $time, dp.arg_a, dp.arg_b, dp.result, bfm.result);
        end;

    end
end : scoreboard_be_blk

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------
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

function void print_test_result (test_result_t tr);
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
// Print the test result at the simulation end
//------------------------------------------------------------------------------
final begin : finish_of_the_test
    print_test_result(test_result);
end

	
endmodule : scoreboard