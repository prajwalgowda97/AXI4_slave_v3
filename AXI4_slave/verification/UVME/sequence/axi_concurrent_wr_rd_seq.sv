class axi_concurrent_wr_rd_seq extends uvm_sequence#(axi_seq_item);

  //factory registration
  `uvm_object_utils(axi_concurrent_wr_rd_seq)

    //creating sequence item handle
    axi_seq_item seq_item_inst;

  int scenario;

  //constructor
  function new(string name="axi_concurrent_wr_rd_seq");
   super.new(name);
  endfunction
  
  //Build phase
  function build_phase(uvm_phase phase);
  seq_item_inst = axi_seq_item::type_id::create("seq_item_inst");
  endfunction
  
  //task body
  task body();

  //reset scenario
        `uvm_info (get_type_name(),"concurrent_wr_rd seq: inside body", UVM_LOW);
       
       if (scenario == 11)
        begin
          `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b0;
            seq_item_inst.AWADDR    == 32'h00000000;
            seq_item_inst.AWVALID   == 1'b0;
            seq_item_inst.WVALID    == 1'b0;
            seq_item_inst.WDATA[0]     == 32'h00000000;
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

if (scenario == 12)
         //repeat(3)
        begin  
             `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b1;
            seq_item_inst.AWVALID   == 1'b1;
            seq_item_inst.WVALID    == 1'b1;
            seq_item_inst.BREADY    == 1'b1;
            seq_item_inst.AWADDR    == 32'h11112222;
            seq_item_inst.WDATA[0]     == 32'haaaabbbb;
            seq_item_inst.AWID      == 4'b1010;
            seq_item_inst.AWLEN     == 8'h00;
            seq_item_inst.AWSIZE    == 3'b101;
            seq_item_inst.AWBURST   == 2'b00;
            seq_item_inst.WSTRB     == 4'b1111;
            seq_item_inst.WLAST     == 1'b0; 
            
            seq_item_inst.ARVALID   == 0;
            seq_item_inst.RREADY    == 0;
            seq_item_inst.ARID      == 0;
            seq_item_inst.ARADDR    == 0;
            seq_item_inst.ARSIZE    == 0;
            seq_item_inst.ARBURST   == 0;
            seq_item_inst.ARLEN     == 0; });
            
            `uvm_info("SEQ", $sformatf("Running scenario = %0d", scenario), UVM_MEDIUM)            
            end

        if (scenario ==13)
            //repeat(3)
        begin
             `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b0;
            seq_item_inst.ARVALID   == 1'b1;
            seq_item_inst.RREADY    == 1'b1;
            seq_item_inst.ARID      == 4'b1010;
            seq_item_inst.ARADDR    == 32'h11112222;
            seq_item_inst.ARSIZE    == 3'b101;
            seq_item_inst.ARBURST   == 2'b00;
            seq_item_inst.ARLEN     == 8'h00;   
            
            seq_item_inst.AWVALID   == 0;
            seq_item_inst.WVALID    == 0;
            seq_item_inst.BREADY    == 0;
            seq_item_inst.AWADDR    == 0;
            seq_item_inst.WDATA[0]     == 0;
            seq_item_inst.AWID      == 0;
            seq_item_inst.AWLEN     == 0;
            seq_item_inst.AWSIZE    == 0;
            seq_item_inst.AWBURST   == 0;
            seq_item_inst.WSTRB     == 0;
            seq_item_inst.WLAST     == 0; });
                       
            end

  endtask
endclass

