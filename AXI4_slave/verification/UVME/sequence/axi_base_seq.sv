class axi_base_seq extends uvm_sequence#(axi_seq_item);

  //factory registration
  `uvm_object_utils(axi_base_seq)

  //creating sequence item handle
  axi_seq_item seq_item_inst;


  //constructor
  function new(string name="axi_base_seq");
   super.new(name);
  endfunction

  //task body
  task body();
 start_item(seq_item_inst);

 finish_item(seq_item_inst);
         
  endtask

endclass


