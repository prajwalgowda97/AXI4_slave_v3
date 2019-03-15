class axi_wrapped_burst_seq extends uvm_sequence#(axi_seq_item);

  //factory registration
  `uvm_object_utils(axi_wrapped_burst_seq)

    //creating sequence item handle
    axi_seq_item seq_item_inst;
    int scenario;

    // Variable to store randomized write address
    bit [31:0] rand_wr_addr; 
    bit [3: 0] rand_wr_id;
    bit [2:0] wr_size;
    bit [1:0] wr_burst;
    bit [7:0] wr_len;

  //constructor
  function new(string name="axi_wrapped_burst_seq");
   super.new(name);
  endfunction
  
  //Build phase
  function build_phase(uvm_phase phase);
  seq_item_inst = axi_seq_item::type_id::create("seq_item_inst");
  endfunction


  //task body
  task body();

  //reset scenario
        `uvm_info (get_type_name(),"wrapped_burst_seq: inside body", UVM_LOW);
       
       if (scenario == 23)
        begin
          `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b0;
            seq_item_inst.AWADDR    == 32'h00000000;
            seq_item_inst.AWVALID   == 1'b0;
            seq_item_inst.WVALID    == 1'b0;
            seq_item_inst.WDATA[0]  == 32'h00000000;
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

if (scenario == 24)
         //repeat(3)
        begin  
            `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b1;
            seq_item_inst.AWVALID   == 1'b1;
            seq_item_inst.WVALID    == 1'b1;
            seq_item_inst.BREADY    == 1'b0;
            seq_item_inst.AWADDR inside {[32'h0000_0000 : 32'hFFFF_FFFF]}; 
            seq_item_inst.WDATA[0]  inside {[32'h0000_0000 : 32'hFFFF_FFFF]};
            seq_item_inst.AWID   inside {[4'h0 : 4'hF]};
            seq_item_inst.AWLEN     == 8'h02;
            seq_item_inst.AWSIZE    == 3'b010;
            seq_item_inst.AWBURST   == 2'b10;
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
            
            // Store the randomized AWADDR value into the class variable
            rand_wr_addr = seq_item_inst.AWADDR;
            rand_wr_id   = seq_item_inst.AWID;
            wr_size      = seq_item_inst.AWSIZE;
            wr_burst     = seq_item_inst.AWBURST;
            wr_len       = seq_item_inst.AWLEN;

            `uvm_info("SEQ", $sformatf("Randomized AWADDR = 0x%0h", rand_wr_addr), UVM_MEDIUM)
            end

        if (scenario == 25)
            //repeat(3)
        begin
              `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b0;
            seq_item_inst.ARVALID   == 1'b1;
            seq_item_inst.RREADY    == 1'b0;
            seq_item_inst.ARID      == rand_wr_id;
            seq_item_inst.ARADDR    == rand_wr_addr;
            seq_item_inst.ARSIZE    == wr_size;
            seq_item_inst.ARBURST   == wr_burst;
            seq_item_inst.ARLEN     == wr_len;   
            
            seq_item_inst.AWVALID   == 0;
            seq_item_inst.WVALID    == 0;
            seq_item_inst.BREADY    == 0;
            seq_item_inst.AWADDR    == 0;
            seq_item_inst.WDATA[0]  == 0;
            seq_item_inst.AWID      == 0;
            seq_item_inst.AWLEN     == 0;
            seq_item_inst.AWSIZE    == 0;
            seq_item_inst.AWBURST   == 0;
            seq_item_inst.WSTRB     == 0;
            seq_item_inst.WLAST     == 0; });
            
            `uvm_info("SEQ", $sformatf("Using AWADDR for ARADDR = 0x%0h", rand_wr_addr), UVM_MEDIUM)
            end

  endtask
endclass

