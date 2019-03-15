class axi_driver extends uvm_driver#(axi_seq_item);

  //factory registration
  `uvm_component_utils(axi_driver)

  //creating interface and sequence item handle
  axi_seq_item seq_item_inst; 
  virtual axi_interface intf;
  int i;
    
  //constructor
  function new(string name = "axi_driver", uvm_component parent);
  super.new(name, parent);
  `uvm_info("Driver_class", "Inside Constructor!", UVM_HIGH)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);

  seq_item_inst = axi_seq_item::type_id::create("seq_item_inst"); // not there in zmc

  if(!uvm_config_db#(virtual axi_interface)::get(this,"","axi_interface",intf))
      begin
      `uvm_fatal(get_full_name(),"unable to get interface in read driver")
      end
      `uvm_info("Driver_class", "Inside Build Phase!", UVM_HIGH)
  endfunction

 //run phase
    task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
    seq_item_port.get_next_item(seq_item_inst);
    reset_signals;

if (seq_item_inst.RST)
    begin
  if (seq_item_inst.wr_rd)
      begin          
      drive_write_address(seq_item_inst);
      drive_write_data(seq_item_inst);
      drive_write_response(seq_item_inst);
      end    
     else
      begin   
      drive_read_address(seq_item_inst);
      drive_read_data(seq_item_inst);
      end 
    end 
    seq_item_port.item_done();
    end 
  endtask 

// Reset task main part
 task reset_signals;
  begin
    // Assert reset
    @(posedge  intf.CLK);
    intf.driver_cb.RST     <=  seq_item_inst.RST     ; 
    intf.driver_cb.AWADDR  <=  seq_item_inst.AWADDR  ;
    intf.driver_cb.AWLEN   <=  seq_item_inst.AWLEN   ;
    intf.driver_cb.AWBURST <=  seq_item_inst.AWBURST ;
    intf.driver_cb.AWID    <=  seq_item_inst.AWID    ;
    intf.driver_cb.AWSIZE  <=  seq_item_inst.AWSIZE  ;
    intf.driver_cb.AWVALID <=  seq_item_inst.AWVALID ;
    intf.driver_cb.WDATA   <=  seq_item_inst.WDATA[i];
    intf.driver_cb.WSTRB   <=  seq_item_inst.WSTRB   ;
    intf.driver_cb.WLAST   <=  seq_item_inst.WLAST   ;
    intf.driver_cb.ARVALID <=  seq_item_inst.ARVALID ;
    intf.driver_cb.WVALID  <=  seq_item_inst.WVALID  ;
  //intf.driver_cb.WID     <=  seq_item_inst.WID     ;
    intf.driver_cb.BREADY  <=  seq_item_inst.BREADY  ;
    intf.driver_cb.ARSIZE  <=  seq_item_inst.ARSIZE  ;
    intf.driver_cb.ARID    <=  seq_item_inst.ARID    ;
    intf.driver_cb.ARADDR  <=  seq_item_inst.ARADDR  ;
    intf.driver_cb.ARLEN   <=  seq_item_inst.ARLEN   ;
    intf.driver_cb.ARBURST <=  seq_item_inst.ARBURST ;
    intf.driver_cb.RREADY  <=  seq_item_inst.RREADY  ;

end
endtask 

    // -----------------------------
    //  Write Address Channel (AW)
    // -----------------------------

     task drive_write_address(axi_seq_item seq_item_inst);
        @(posedge intf.CLK);

        intf.driver_cb.AWVALID  <= 1;
        intf.driver_cb.AWID     <= seq_item_inst.AWID   ;
        intf.driver_cb.AWADDR   <= seq_item_inst.AWADDR ;
        intf.driver_cb.AWLEN    <= seq_item_inst.AWLEN  ;
        intf.driver_cb.AWSIZE   <= seq_item_inst.AWSIZE ;
        intf.driver_cb.AWBURST  <= seq_item_inst.AWBURST;
        
        // Wait for AWREADY from Slave
        //@(posedge intf.CLK);
        wait(intf.driver_cb.AWREADY) @(posedge intf.CLK);
        `uvm_info("AXI_WRITE_DRIVER", $sformatf("AWREADY=%b", intf.driver_cb.AWREADY), UVM_MEDIUM)
        
        intf.driver_cb.AWVALID  <= 0;
        intf.driver_cb.AWID     <= 0;
        intf.driver_cb.AWADDR   <= 0;
        intf.driver_cb.AWLEN    <= 0;
        intf.driver_cb.AWSIZE   <= 0;
        intf.driver_cb.AWBURST  <= 0;

      endtask 

    // -----------------------------
    //  Write Data Channel (W)
    // -----------------------------

 task drive_write_data(axi_seq_item seq_item_inst);

    for (int i = 0; i <= seq_item_inst.AWLEN +1 ; i++) begin

    // Drive WVALID, WDATA, WSTRB, and WLAST
    @(posedge intf.CLK);
    intf.driver_cb.WVALID <= 1;
    intf.driver_cb.WDATA  <= seq_item_inst.WDATA[i];
    intf.driver_cb.WSTRB  <= seq_item_inst.WSTRB;
    intf.driver_cb.WLAST  <= (i == seq_item_inst.AWLEN ); 


    // Wait until WREADY is high before sending next data beat
    //@(posedge intf.CLK);
    wait(intf.driver_cb.WREADY == 1);
    end

  // De-assert WVALID after last data beat
  //@(posedge intf.CLK);
    intf.driver_cb.WVALID <= 0;
    intf.driver_cb.WDATA  <= 0;
    intf.driver_cb.WSTRB  <= 0;
    intf.driver_cb.WLAST  <= 0;
    intf.driver_cb.BREADY <= 0;

  endtask 
    
    // -----------------------------
    //  Write Response Channel (B)
    // -----------------------------
    task drive_write_response(axi_seq_item seq_item_inst);
        //@(posedge intf.CLK);
        intf.driver_cb.BREADY <= 1; // Master drives BREADY
        
       // @(posedge intf.CLK);
        wait(intf.driver_cb.BVALID)
        @(posedge intf.CLK);
        intf.driver_cb.BREADY <= 0;
     endtask 


/* task drive_write_response(axi_seq_item seq_item_inst);
    
    // Wait for BVALID to be asserted first
   // @(posedge intf.CLK);
    wait(intf.driver_cb.BVALID);  // Wait for BVALID signal

    // After BVALID is high, assert BREADY
    @(posedge intf.CLK);
    intf.driver_cb.BREADY <= 1;   // Master drives BREADY high

    // Deassert BREADY after a clock cycle
    @(posedge intf.CLK);
    intf.driver_cb.BREADY <= 0; 

endtask */

    // -----------------------------
    //  Read Address Channel (AR)
    // -----------------------------
    task drive_read_address(axi_seq_item seq_item_inst);
        @(posedge intf.CLK);
        intf.driver_cb.ARADDR   <= seq_item_inst.ARADDR;
        intf.driver_cb.ARLEN    <= seq_item_inst.ARLEN;
        intf.driver_cb.ARBURST  <= seq_item_inst.ARBURST;
        intf.driver_cb.ARID     <= seq_item_inst.ARID;
        intf.driver_cb.ARSIZE   <= seq_item_inst.ARSIZE;
        intf.driver_cb.ARVALID  <= 1;

        // Wait for ARREADY from Slave
        wait(intf.driver_cb.ARREADY)
        @(posedge intf.CLK);
        `uvm_info("AXI_READ_DRIVER", $sformatf("ARREADY=%b", intf.driver_cb.ARREADY), UVM_MEDIUM)

        intf.driver_cb.ARVALID  <= 0;
        intf.driver_cb.ARADDR   <= 0;
        intf.driver_cb.ARLEN    <= 0;
        intf.driver_cb.ARBURST  <= 0;
        intf.driver_cb.ARID     <= 0;
        intf.driver_cb.ARSIZE   <= 0;

    endtask

    // -----------------------------
    //  Read Data Channel (R)
    // -----------------------------
    task drive_read_data(axi_seq_item seq_item_inst);
        //@(posedge intf.CLK);
        wait (intf.driver_cb.RVALID) @(posedge intf.CLK);

        intf.driver_cb.RREADY <= 1; // Master drives RREADY

        for (int i = 0; i <= seq_item_inst.ARLEN + 1; i++) begin
        // Wait for RVALID from Slave
        wait (intf.driver_cb.RVALID) @(posedge intf.CLK);
        //intf.driver_cb.RREADY <= 1; // Master drives RREADY

        end

        @(posedge intf.CLK);
        intf.driver_cb.RREADY <= 0;
    endtask 
endclass
