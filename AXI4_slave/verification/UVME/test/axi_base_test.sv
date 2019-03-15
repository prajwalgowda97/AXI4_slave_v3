 class axi_base_test extends uvm_test;

  //factory registration
  `uvm_component_utils(axi_base_test)

  //creating environment and sequence handle
  axi_env env_inst;
  axi_base_seq base_seq_inst;  
  
  //constructor
  function new(string name = "axi_base_test",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(), "Inside Constuctor!", UVM_HIGH) 
  endfunction 
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_inst = axi_env::type_id::create("env_inst",this); 
    base_seq_inst = axi_base_seq::type_id::create("base_seq_inst");
    `uvm_info(get_type_name(), "Inside Build Phase!", UVM_HIGH)
  endfunction

//end of elaboration phase
	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

task run_phase(uvm_phase phase);
    phase.raise_objection(this);

   // base_seq_inst.start(evn_inst.agent_inst.seqr_inst);
    phase.drop_objection(this);
  endtask

endclass 
