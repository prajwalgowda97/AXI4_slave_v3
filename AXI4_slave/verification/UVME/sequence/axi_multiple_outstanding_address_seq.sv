class axi_multiple_outstanding_address_seq extends uvm_sequence#(axi_seq_item);

  //factory registration
  `uvm_object_utils(axi_multiple_outstanding_address_seq)

    //creating sequence item handle
    axi_seq_item seq_item_inst;
    int scenario;
    int i = 0;

    // Variable to store randomized write address
    bit [31:0] rand_wr_addr[4]; 
    bit [3: 0] rand_wr_id[4];
    bit [2:0] wr_size[4];
    bit [1:0] wr_burst[4];
    bit [7:0] wr_len[4];

  //constructor
  function new(string name="axi_multiple_outstanding_address_seq");
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
      
       if (scenario == 26)
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

if (scenario == 27) 
        begin
        repeat(3)
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
            seq_item_inst.AWBURST   == 2'b01;
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
            rand_wr_addr[i] = seq_item_inst.AWADDR;
            rand_wr_id[i]   = seq_item_inst.AWID;
            wr_size[i]      = seq_item_inst.AWSIZE;
            wr_burst [i]    = seq_item_inst.AWBURST;
            wr_len [i]      = seq_item_inst.AWLEN;

            `uvm_info("SEQ", $sformatf("Randomized AWADDR = 0x%0h", rand_wr_addr), UVM_MEDIUM)
             `uvm_info("i", $sformatf("i value = %0d", i), UVM_MEDIUM) 

            for (int j = 0; j < i; j++) begin
            `uvm_info("SEQ", $sformatf("rand_wr_addr[%0d] = 0x%0h", j, rand_wr_addr[j]), UVM_MEDIUM)
            end

            // for (int j = 0; j < i; j++) 
            begin
            `uvm_info("SEQ", $sformatf("AWADDR = 0x%0h", seq_item_inst.AWADDR), UVM_MEDIUM)
            end

            i++;

            end
            end

        if (scenario == 28) 
        begin
        for (int i = 0; i < 3; i++) 
         begin

                int temp_arid    = rand_wr_id[i];
                int temp_araddr  = rand_wr_addr[i];
                int temp_arsize  = wr_size[i];
                int temp_arburst = wr_burst[i];
                int temp_arlen   = wr_len[i];

            `uvm_do_with(seq_item_inst,{
            seq_item_inst.RST       == 1'b1;
            seq_item_inst.wr_rd     == 1'b0;
            seq_item_inst.ARVALID   == 1'b1;
            seq_item_inst.RREADY    == 1'b0;
            seq_item_inst.ARID     == temp_arid;    
            seq_item_inst.ARADDR   == temp_araddr; 
            seq_item_inst.ARSIZE   == temp_arsize;
            seq_item_inst.ARBURST  == temp_arburst;
            seq_item_inst.ARLEN    == temp_arlen; 
            
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

                
            `uvm_info("i", $sformatf("i value = %0d", i), UVM_MEDIUM) 
            end
            end
                    
  endtask
endclass 
