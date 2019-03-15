class axi_fixed_burst_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_fixed_burst_test)
  axi_fixed_burst_seq fixed_burst_seq_inst;

  //constructor
  function new(string name = "axi_fixed_burst_test",uvm_component parent);
    super.new(name,parent);
    fixed_burst_seq_inst = axi_fixed_burst_seq::type_id::create("fixed_burst_seq_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
   virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test fixed_burst first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the fixed_burst test"),UVM_MEDIUM)
   
   begin
    fixed_burst_seq_inst.scenario = 17;
    fixed_burst_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("fixed_burst scenario 14 is competed"),UVM_MEDIUM)
 
    begin
    fixed_burst_seq_inst.scenario = 18;
    fixed_burst_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("fixed_burst scenario 15 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    begin
    fixed_burst_seq_inst.scenario = 19;
    fixed_burst_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("fixed_burst scenario 16 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    phase.drop_objection(this);
   endtask
  endclass
