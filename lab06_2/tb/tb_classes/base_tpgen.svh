virtual class base_tpgen extends uvm_component;
	
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
	
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function logic signed [15:0] get_data();
    //pure virtual protected function logic signed [3:0] get_parity(logic signed [15:0] arg_a, logic signed [15:0] arg_b);

    
    protected function logic [3:0] get_parity(
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
    	return {arg_a_parity,arg_b_parity,flag_arg_a_parity,flag_arg_b_parity}; 
   
    endfunction : get_parity
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		command_s command;
	
		phase.raise_objection(this);
		command.rst_n = 1;
        command_port.put(command);
		command.rst_n = 0;
		
	    repeat (1000) begin : random_loop
	        command.arg_a = get_data();
	        command.arg_b = get_data();
		    {command.arg_a_parity, command.arg_b_parity, command.flag_arg_a_parity, command.flag_arg_b_parity }= get_parity(command.arg_a, command.arg_b);

		    
		    command_port.put(command);
	    end : random_loop
	    
	    command.rst_n = 1;
        command_port.put(command);
	    command_port.put(command);	
	    
	    phase.drop_objection(this);
	endtask : run_phase
	
endclass : base_tpgen