class axi_handshake_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_handshake_test)
  axi_handshake_seq handshake_seq_inst;

  //constructor
  function new(string name = "axi_handshake_test",uvm_component parent);
    super.new(name, parent);
    handshake_seq_inst = axi_handshake_seq::type_id::create("handshake_seq_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test handshake first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the handshake test"),UVM_MEDIUM)
    
    begin
    handshake_seq_inst.scenario = 4;
    handshake_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("handshake scenario 1 is competed"),UVM_MEDIUM)
    
    
    begin
    //repeat(2) 
    begin
    handshake_seq_inst.scenario = 5;
    handshake_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end
    end
    `uvm_info(get_type_name(),$sformatf("handshake scenario 2 is competed"),UVM_MEDIUM)
    
    
    begin
    //repeat(2)
    handshake_seq_inst.scenario = 6;
    handshake_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end
    `uvm_info(get_type_name(),$sformatf("handshake scenario 3 is competed"),UVM_MEDIUM)

    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,1000);

  endtask

endclass
