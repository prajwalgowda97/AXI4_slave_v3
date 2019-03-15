class axi_reset_seq extends uvm_sequence#(axi_seq_item);

  //factory registration
  `uvm_object_utils(axi_reset_seq)

  //creating sequence item handle
  axi_seq_item seq_item_inst;

  int scenario;

  //constructor
  function new(string name="axi_reset_seq");
   super.new(name);
  endfunction
  
  //Build phase
  function build_phase(uvm_phase phase);
  seq_item_inst = axi_seq_item::type_id::create("seq_item_inst");
  endfunction
  
  //task body
  task body();

 //reset scenario
        `uvm_info (get_type_name(),"Reset seq: inside body", UVM_LOW);
       
       if (scenario == 1)
        begin
        `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b0;
            seq_item_inst.AWADDR    == 32'h00000000;
            seq_item_inst.AWVALID   == 1'b0;
            seq_item_inst.WVALID    == 1'b0;
            seq_item_inst.WDATA[0][0]     == 32'h00000000;
            seq_item_inst.BREADY    == 1'b0;
            seq_item_inst.AWID      == 0;
            seq_item_inst.AWSIZE    == 0;
            seq_item_inst.ARID      == 0;
            seq_item_inst.ARSIZE    == 0;
            seq_item_inst.AWLEN     == 0;
            seq_item_inst.AWBURST   == 0;
            seq_item_inst.WSTRB     == 0;
            seq_item_inst.WLAST     == 0;
            seq_item_inst.ARVALID   == 0;
            seq_item_inst.ARADDR    == 0;
            seq_item_inst.ARLEN     == 0;
            seq_item_inst.ARBURST   == 0;
            seq_item_inst.RREADY    == 0;   });
                       
            end

if (scenario == 2)
        begin  
         `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b1;
            seq_item_inst.AWVALID   == 1'b1;
            seq_item_inst.WVALID    == 1'b1;
            seq_item_inst.BREADY    == 1'b1;
            seq_item_inst.AWLEN     == 8'h0;
            seq_item_inst.WLAST     == 0; 
       /*    seq_item_inst.AWID      == 0;
            seq_item_inst.AWADDR    == 32'h00000000;
            seq_item_inst.AWSIZE    == 0;
            seq_item_inst.AWBURST   == 0;
            seq_item_inst.WDATA[0]     == 32'h00000000;
            seq_item_inst.WSTRB     == 0;
            */  });
            
            end

        if (scenario == 3)
        begin
         `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b0;
            seq_item_inst.ARVALID   == 1'b1;
            seq_item_inst.RREADY    == 1'b1;
         /*  seq_item_inst.ARID      == 32'h00000000;
            seq_item_inst.ARADDR    == 0;
            seq_item_inst.ARSIZE    == 0;
            seq_item_inst.ARBURST   == 0;
            seq_item_inst.ARADDR    == 0;
            seq_item_inst.ARLEN     == 0;
            seq_item_inst.ARBURST   == 0;   */ });
                       
            end

endtask 

endclass
