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