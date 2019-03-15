class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_interface intf;

    // Separate analysis ports for write and read
    uvm_analysis_port #(axi_seq_item) wr_analysis_port;
    uvm_analysis_port #(axi_seq_item) rd_analysis_port;

    function new(string name = "axi_monitor", uvm_component parent);
        super.new(name, parent);
        wr_analysis_port = new("wr_analysis_port", this);
        rd_analysis_port = new("rd_analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_interface", intf))
            `uvm_fatal("MONITOR", "Failed to get interface handle from config DB")
    endfunction

    task run_phase(uvm_phase phase);
        axi_seq_item write_item;
        axi_seq_item read_item;

        forever begin
            @(posedge intf.CLK);

            // ---- WRITE TRANSACTION ----
            if (intf.AWVALID && intf.AWREADY) begin
                write_item = axi_seq_item::type_id::create("write_item");

                write_item.wr_rd   = 1'b1;
                write_item.AWID    = intf.AWID;
                write_item.AWADDR  = intf.AWADDR;
                write_item.AWLEN   = intf.AWLEN;
                write_item.AWSIZE  = intf.AWSIZE;
                write_item.AWBURST = intf.AWBURST;

                `uvm_info("MONITOR - AW_CHANNEL", $sformatf(
                    "AWID=0x%0h, AWADDR=0x%0h, AWLEN=%0d, AWSIZE=%0d, AWBURST=%0d", 
                    write_item.AWID, write_item.AWADDR, 
                    write_item.AWLEN, write_item.AWSIZE, 
                    write_item.AWBURST), UVM_HIGH)

                // Capture write data beats
                for (int i = 0; i <= intf.AWLEN; i++) begin
                    @(posedge intf.CLK);
                    wait (intf.WVALID && intf.WREADY);

                    write_item.WDATA.push_back(intf.WDATA);
                    write_item.WSTRB = intf.WSTRB;
                    write_item.WLAST = intf.WLAST;

                    `uvm_info("MONITOR - W_CHANNEL", $sformatf(
                        "WDATA=0x%0p, WSTRB=0x%0p, WLAST=0x%0d", 
                        write_item.WDATA, write_item.WSTRB, write_item.WLAST), UVM_HIGH)

                    if (intf.WLAST) break;
                end

                // Capture write response
                @(posedge intf.CLK);
                wait (intf.BVALID && intf.BREADY);
                write_item.BRESP = intf.BRESP;
                write_item.BID   = intf.BID;

                `uvm_info("MONITOR - B_CHANNEL", $sformatf(
                    "BRESP=0x%0h, BID=0x%0h", 
                    write_item.BRESP, write_item.BID), UVM_HIGH)

                // Send to scoreboard
                wr_analysis_port.write(write_item);
            end

            // ---- READ TRANSACTION ----
            if (intf.ARVALID && intf.ARREADY) begin
                read_item = axi_seq_item::type_id::create("read_item");

                read_item.wr_rd   = 1'b0;
                read_item.ARID    = intf.ARID;
                read_item.ARADDR  = intf.ARADDR;
                read_item.ARLEN   = intf.ARLEN;
                read_item.ARSIZE  = intf.ARSIZE;
                read_item.ARBURST = intf.ARBURST;

                `uvm_info("MONITOR - AR_CHANNEL", $sformatf(
                    "ARID=0x%0h, ARADDR=0x%0h, ARLEN=%0d, ARSIZE=%0d, ARBURST=%0d", 
                    read_item.ARID, read_item.ARADDR, 
                    read_item.ARLEN, read_item.ARSIZE, 
                    read_item.ARBURST), UVM_HIGH)

                // Capture read data beats
                for (int i = 0; i <= intf.ARLEN; i++) begin
                    @(posedge intf.CLK);
                    wait (intf.RVALID && intf.RREADY);

                    read_item.RDATA = intf.RDATA;
                    read_item.RRESP = intf.RRESP;
                    read_item.RLAST = intf.RLAST;

                    `uvm_info("MONITOR - R_CHANNEL", $sformatf(
                        "RDATA=0x%0h, RRESP=0x%0h, RLAST=0x%0b", 
                        read_item.RDATA, read_item.RRESP, read_item.RLAST), UVM_HIGH)

                    if (intf.RLAST) break;
                end

                // Send to scoreboard
                rd_analysis_port.write(read_item);
            end
        end
    endtask
endclass

