class axi_reset_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_reset_test)
  axi_reset_seq reset_seq_inst;

  //constructor
  function new(string name = "axi_reset_test",uvm_component parent);
    super.new(name,parent);
    reset_seq_inst = axi_reset_seq::type_id::create("reset_seq_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test reset first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the reset test"),UVM_MEDIUM)
    
    begin
    reset_seq_inst.scenario = 1;
    reset_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("reset scenario 1 is competed"),UVM_MEDIUM)
    
    
    begin
    //repeat(2) 
    begin
    reset_seq_inst.scenario = 2;
    reset_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end
    end
    `uvm_info(get_type_name(),$sformatf("reset scenario 2 is competed"),UVM_MEDIUM)
    
    
    begin
    //repeat(2)
    reset_seq_inst.scenario = 3;
    reset_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end
    `uvm_info(get_type_name(),$sformatf("reset scenario 3 is competed"),UVM_MEDIUM)

    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,1000);

  endtask

endclass
