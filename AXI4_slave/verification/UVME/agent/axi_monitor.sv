class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_interface intf;
    uvm_analysis_port #(axi_seq_item) analysis_port;
    axi_seq_item seq_item_inst;

    // Constructor
    function new(string name = "axi_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get interface handle from configuration database
        if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_interface", intf)) begin
            `uvm_fatal("MONITOR", "Unable to get interface handle from config DB")
        end
    endfunction

    // Run Phase
task run_phase(uvm_phase phase);
    forever begin
        @(posedge intf.CLK);

        // Write Address Channel
        if (intf.AWVALID && intf.AWREADY) begin
            seq_item_inst = axi_seq_item::type_id::create("seq_item_inst");  // Create new instance

            // Capture Write Address Channel signals
            seq_item_inst.AWID = intf.AWID;
            seq_item_inst.AWADDR = intf.AWADDR;
            seq_item_inst.AWLEN = intf.AWLEN;
            seq_item_inst.AWSIZE = intf.AWSIZE;
            seq_item_inst.AWBURST = intf.AWBURST;

            `uvm_info("AW_CHANNEL", $sformatf(
                "AWID=0x%0h, AWADDR=0x%0h, AWLEN=%0d, AWSIZE=%0d, AWBURST=%0d", 
                seq_item_inst.AWID,
                seq_item_inst.AWADDR, 
                seq_item_inst.AWLEN, 
                seq_item_inst.AWSIZE, 
                seq_item_inst.AWBURST
            ), UVM_HIGH)
        end

        // Write Data Channel
        if (intf.WVALID && intf.WREADY) begin
            seq_item_inst.WDATA.push_back(intf.WDATA);  // Collect WDATA properly
            seq_item_inst.WSTRB = intf.WSTRB;
            seq_item_inst.WLAST = intf.WLAST;

            `uvm_info("W_CHANNEL", $sformatf(
                "WDATA=0x%0p, WSTRB=0x%0p, WLAST=0x%0d", 
                seq_item_inst.WDATA, 
                seq_item_inst.WSTRB,
                seq_item_inst.WLAST
            ), UVM_HIGH)

            `uvm_info("W_CHANNEL", $sformatf("WDATA queue size = %0d", seq_item_inst.WDATA.size()), UVM_HIGH)
        end

        // Write Response Channel
        if (intf.BVALID && intf.BREADY) begin
            seq_item_inst.BRESP = intf.BRESP;

            `uvm_info("B_CHANNEL", $sformatf("BRESP=0x%0h", seq_item_inst.BRESP), UVM_HIGH)

            // Write to analysis port
            analysis_port.write(seq_item_inst);
        end

        // Read Address Channel
        if (intf.ARVALID && intf.ARREADY) begin
            seq_item_inst = axi_seq_item::type_id::create("seq_item_inst");  // New instance for AR channel
            
            seq_item_inst.ARID = intf.ARID;
            seq_item_inst.ARADDR = intf.ARADDR;
            seq_item_inst.ARLEN = intf.ARLEN;
            seq_item_inst.ARSIZE = intf.ARSIZE;
            seq_item_inst.ARBURST = intf.ARBURST;

            `uvm_info("AR_CHANNEL", $sformatf(
                "ARID=0x%0h, ARADDR=0x%0h, ARLEN=%0d, ARSIZE=%0d, ARBURST=%0d", 
                seq_item_inst.ARADDR, 
                seq_item_inst.ARID, 
                seq_item_inst.ARLEN, 
                seq_item_inst.ARSIZE, 
                seq_item_inst.ARBURST
            ), UVM_HIGH)
        end 

        // Read Data Channel
        if (intf.RVALID && intf.RREADY) begin
            seq_item_inst.RDATA = intf.RDATA;
            seq_item_inst.RRESP = intf.RRESP;

            `uvm_info("R_CHANNEL", $sformatf(
                "RDATA=0x%0p, RRESP=0x%0h", 
                seq_item_inst.RDATA, 
                seq_item_inst.RRESP
            ), UVM_HIGH)

            // Write to analysis port
            analysis_port.write(seq_item_inst);
        end
    end
endtask
    
endclass 

