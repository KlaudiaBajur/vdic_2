class tpgen extends uvm_component;
	`uvm_component_utils (tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    uvm_put_port #(command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase



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


	
function logic [3:0] get_parity(
		logic signed [15:0] arg_a,
		logic signed [15:0] arg_b
		);
    	bit  zero_ones;
		bit  zero_ones_2;
		bit counter;
		logic arg_a_parity;
		logic arg_b_parity;
		bit flag_arg_a_parity;
		bit flag_arg_b_parity;

    	zero_ones = 1'($random);
		zero_ones_2 = 1'($random);
	
    	if (zero_ones == 1'b1)begin
	    	arg_a_parity=~^arg_a;
    		flag_arg_a_parity =1'b1;
		end
    	else begin
        	arg_a_parity=^arg_a;
	    	flag_arg_a_parity=1'b0;
    	end
    	
    	if (zero_ones_2 == 1'b1) begin
	    	arg_b_parity=~^arg_a;
    		flag_arg_b_parity =1'b1;
		end
    	else begin
        	arg_b_parity=^arg_b;
	    	flag_arg_b_parity=1'b0;
    	end
    	return {arg_a_parity,arg_b_parity,flag_arg_a_parity,flag_arg_b_parity}; 
   
endfunction : get_parity
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		command_transaction command;
	
		phase.raise_objection(this);
		command = new("command");
		command.rst_n = 1;
        command_port.put(command);
		
		command = command_transaction::type_id::create("command");
		
        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        `uvm_info("TPGEN", $sformatf("*** Created transaction type: %s",command.get_type_name()), UVM_MEDIUM);
        set_print_color(COLOR_DEFAULT);
		
	    repeat (5000) begin
            assert(command.randomize());
            command.arg_a = get_data();
        	command.arg_b  = get_data();
 			{command.arg_a_parity, command.arg_b_parity, command.flag_arg_a_parity, command.flag_arg_b_parity} = get_parity(command.arg_a, command.arg_b); 
            command_port.put(command);
	    end
	    
	    command = new("command");
	    command.rst_n = 1;
        command_port.put(command);
	    command_port.put(command);	
	    

	    phase.drop_objection(this);
	endtask : run_phase
	
endclass : tpgen

