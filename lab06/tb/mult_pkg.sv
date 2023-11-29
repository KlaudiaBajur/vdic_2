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
`timescale 1ns/1ps
package mult_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// package typedefs
//------------------------------------------------------------------------------

    // terminal print colors
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;


//------------------------------------------------------------------------------
// package functions
//------------------------------------------------------------------------------
    typedef struct packed {
	    logic signed [15:0] arg_a;
        logic signed [15:0] arg_b;
	    logic arg_a_parity;
	    logic arg_b_parity;
	    bit flag_arg_a_parity;
	    bit flag_arg_b_parity;
	    logic               rst_n;
	    logic signed [31:0] result;
    } command_s;
	

    // used to modify the color of the text printed on the terminal

    function void set_print_color ( print_color c );
        string ctl;
        case(c) 
            COLOR_BOLD_BLACK_ON_GREEN : ctl = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl       = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl    = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl      = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl           = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl                 = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                             = "";
            end
        endcase
        $write(ctl);
    endfunction

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
`include "coverage.svh"
`include "base_tpgen.svh"
`include "random_tpgen.svh"
`include "add_tpgen.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
`include "random_test.svh"
`include "add_test.svh"

endpackage : mult_pkg
