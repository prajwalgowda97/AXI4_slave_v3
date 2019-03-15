class axi_multiple_outstanding_address_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_multiple_outstanding_address_test)
   axi_multiple_outstanding_address_seq multiple_outstanding_address_inst;

  //constructor
  function new(string name = "axi_multiple_outstanding_address_test",uvm_component parent);
    super.new(name,parent);
    multiple_outstanding_address_inst = axi_multiple_outstanding_address_seq::type_id::create("multiple_outstanding_address_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
   virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test increment_burst first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the increment_burst test"),UVM_MEDIUM)

    begin
    multiple_outstanding_address_inst.scenario = 26;
    multiple_outstanding_address_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("increment_burst scenario 26 is competed"),UVM_MEDIUM)
 
    begin
    multiple_outstanding_address_inst.scenario = 27;
    multiple_outstanding_address_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("increment_burst scenario 27 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    begin
    multiple_outstanding_address_inst.scenario = 28;
    multiple_outstanding_address_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("increment_burst scenario 28 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    phase.drop_objection(this);
   endtask
  endclass

