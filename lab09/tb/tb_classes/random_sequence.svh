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
class random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(random_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
// not necessary, req is inherited
//    sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "random_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        `uvm_info("SEQ_RANDOM", "", UVM_MEDIUM)

//       req = sequence_item::type_id::create("req");
        `uvm_create(req);
	    req.rst_n = 1;
        `uvm_rand_send(req)
	    `uvm_create(req);
	    req.rst_n = 0;
        repeat (2000) begin : random_loop

			req.flag_arg_a_parity = 1'b1;
        	req.flag_arg_b_parity = 1'b1;
            `uvm_rand_send(req)
        end : random_loop
        repeat (2000) begin : random_loop_1

			req.flag_arg_a_parity = 1'b1;
        	req.flag_arg_b_parity = 1'b0;
            `uvm_rand_send(req)
        end : random_loop_1
        repeat (2000) begin : random_loop_2
			req.flag_arg_a_parity = 1'b0;
        	req.flag_arg_b_parity = 1'b1;
            `uvm_rand_send(req)
        end : random_loop_2
    endtask : body

endclass : random_sequence











