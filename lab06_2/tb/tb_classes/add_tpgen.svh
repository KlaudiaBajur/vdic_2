class add_tpgen extends random_tpgen;
    `uvm_component_utils(add_tpgen)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_op - generate random opcode for the tpgen
//------------------------------------------------------------------------------
	protected function logic signed [15:0] get_data();
	    bit zero_one = 1'($random);
	    if (zero_one == 1'b1)
	        return 16'sh8000;			
	    else		
	        return 16'sh7FFF;				  
	endfunction : get_data


endclass : add_tpgen