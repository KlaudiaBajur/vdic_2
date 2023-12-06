class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
	
//---------------------------------
// Random data generation functions
//---------------------------------
	protected function logic signed [15:0] get_data();
	    bit  zero_ones;
    	zero_ones = 1'($random);
       	return 16'($random); 
 
	endfunction : get_data
	
	
	
	
endclass : random_tpgen