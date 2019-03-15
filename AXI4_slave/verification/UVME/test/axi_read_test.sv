class axi_read_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_read_test)
  axi_read_seq read_seq_inst;

  //constructor
  function new(string name = "axi_read_test",uvm_component parent);
    super.new(name,parent);
    read_seq_inst = axi_read_seq::type_id::create("read_seq_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
   virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test read first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the read test"),UVM_MEDIUM)
   
   begin
    read_seq_inst.scenario = 9;
    read_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("read scenario 9 is competed"),UVM_MEDIUM)

    begin
    read_seq_inst.scenario = 10;
    read_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("read_seq_inst scenario 10 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    begin
    read_seq_inst.scenario = 11;
    read_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("read scenario 11 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    phase.drop_objection(this);
   endtask
  endclass
