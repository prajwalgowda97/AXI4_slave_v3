class axi_concurrent_wr_rd_test extends axi_base_test;

  //factory registration
  `uvm_component_utils(axi_concurrent_wr_rd_test)
  axi_concurrent_wr_rd_seq concurrent_wr_rd_seq_inst;

  //constructor
  function new(string name = "axi_concurrent_wr_rd_test",uvm_component parent);
    super.new(name,parent);
    concurrent_wr_rd_seq_inst = axi_concurrent_wr_rd_seq::type_id::create("concurrent_wr_rd_seq_inst");
  endfunction
 
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //run phase
   virtual task run_phase(uvm_phase phase);
    `uvm_info(get_full_name(),$sformatf("it test concurrent_wr_rd first line"),UVM_MEDIUM)
    phase.raise_objection(this);

    `uvm_info(get_type_name(),$sformatf("inside the concurrent_wr_rd test"),UVM_MEDIUM)
   
   begin
    concurrent_wr_rd_seq_inst.scenario = 11;
    concurrent_wr_rd_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("concurrent_wr_rd scenario 11 is competed"),UVM_MEDIUM)
 
    begin
    concurrent_wr_rd_seq_inst.scenario = 12;
    concurrent_wr_rd_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("concurrent_wr_rd scenario 12 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    begin
    concurrent_wr_rd_seq_inst.scenario = 13;
    concurrent_wr_rd_seq_inst.start(env_inst.agent_inst.seqr_inst);
    end  
    `uvm_info(get_type_name(),$sformatf("concurrent_wr_rd scenario 13 is competed"),UVM_MEDIUM)
        
    phase.phase_done.set_drain_time(this,1000);

    phase.drop_objection(this);
   endtask
  endclass
