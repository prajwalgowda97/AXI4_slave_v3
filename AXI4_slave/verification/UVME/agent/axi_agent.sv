class axi_agent extends uvm_agent;
    //factory registration
    `uvm_component_utils(axi_agent)
    //creating driver, monitor & sequencer handle
    axi_driver driver_inst;
    axi_monitor mon_inst;
    axi_seqr seqr_inst;

    //constructor
    function new (string name = "axi_agent", uvm_component parent);
      super.new(name, parent);
      `uvm_info("agent_class", "Inside constructor!", UVM_HIGH)
    endfunction
    
    //build phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      driver_inst = axi_driver::type_id::create("driver_inst",this);
      mon_inst = axi_monitor::type_id::create("mon_inst",this);
      seqr_inst = axi_seqr::type_id::create("seqr_inst",this);
      `uvm_info("agent_class", "Inside Build Phase!", UVM_HIGH)
    endfunction
    
    //connect phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      driver_inst.seq_item_port.connect(seqr_inst.seq_item_export);
      `uvm_info("agent_class", "Inside Connect Phase!", UVM_HIGH)
    endfunction
endclass

