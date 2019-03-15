class axi_seqr extends uvm_sequencer#(axi_seq_item);

  //factory registration
  `uvm_component_utils(axi_seqr)

  //constructor
  function new(string name="axi_seqr",uvm_component parent);
   super.new(name,parent);
   `uvm_info("Sequencer_class", "Inside Constructor!", UVM_HIGH)
   endfunction
   //build phase
   function void build_phase(uvm_phase phase);
   super.build_phase(phase);
  endfunction
  
endclass
