class axi_write_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_write_test)
  axi_write_seq write_seq_inst;

  //constructor
  function new(string name = "axi_write_test",uvm_component parent);
    super.new(name,parent);
    write_seq_inst = axi_write_seq::type_id::create("write_seq_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
   virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test write first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the write test"),UVM_MEDIUM)
   
   begin
    write_seq_inst.scenario = 7;
    write_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("write scenario 7 is competed"),UVM_MEDIUM)
 
    begin
    write_seq_inst.scenario = 8;
    write_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("write scenario 8 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    phase.drop_objection(this);
   endtask
  endclass
