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
class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------
    protected function logic signed [15:0] get_data();
    	bit [3:0] zero_ones;
    	zero_ones = 4'($random);
    	if (zero_ones == 4'b0000)
        	return 16'sh8000; 
    	else if (zero_ones == 4'b1111)
        	return 16'sh7FFF;  
    	else
        	return 16'($random);
	endfunction : get_data

endclass : random_tpgen
