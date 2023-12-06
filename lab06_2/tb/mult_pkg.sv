`timescale 1ns/1ps

package mult_pkg;
    import uvm_pkg::*;
	`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// package typedefs
//------------------------------------------------------------------------------
	typedef enum{
	    COLOR_BOLD_BLACK_ON_GREEN,
	    COLOR_BOLD_BLACK_ON_RED,
	    COLOR_BOLD_BLACK_ON_YELLOW,
	    COLOR_BOLD_BLUE_ON_WHITE,
	    COLOR_BLUE_ON_WHITE,
	    COLOR_DEFAULT
	} print_color_t;

    // MULT data packet
    typedef struct packed {
		bit 					rst_n;
		logic signed 	[15:0] 	arg_a;
		bit               		arg_a_parity;
		logic signed 	[15:0] 	arg_b;        
		bit               		arg_b_parity;
	    bit 					flag_arg_a_parity;
		bit 					flag_arg_b_parity;
    } command_s;
	
	// RESULT data packet
	typedef struct packed {
		logic signed 	[31:0] 	result;
		logic 					arg_parity_error;
	} result_s;

//------------------------------------------------------------------------------
// package functions
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

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
	`include "base_tpgen.svh"
	`include "random_tpgen.svh"
	`include "add_tpgen.svh"

	`include "command_monitor.svh"
	`include "result_monitor.svh"
	`include "driver.svh"

	`include "coverage.svh"
	`include "scoreboard.svh"
	`include "env.svh"
	
//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
	`include "random_test.svh"
	`include "add_test.svh"
	
endpackage : mult_pkg