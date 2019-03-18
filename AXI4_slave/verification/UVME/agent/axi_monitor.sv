class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_interface intf;

    // Separate analysis ports
    uvm_analysis_port #(axi_seq_item) wr_analysis_port;
    uvm_analysis_port #(axi_seq_item) rd_analysis_port;
    uvm_analysis_port #(axi_seq_item) handshake_port;

    function new(string name = "axi_monitor", uvm_component parent);
        super.new(name, parent);
        wr_analysis_port = new("wr_analysis_port", this);
        rd_analysis_port = new("rd_analysis_port", this);
        handshake_port   = new("handshake_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_interface)::get(this, "", "axi_interface", intf))
            `uvm_fatal("MONITOR", "Failed to get interface handle from config DB");
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge intf.CLK);

            // ---- HANDSHAKE: AWVALID & AWREADY ----
            if (intf.AWVALID && intf.AWREADY) begin
                axi_seq_item hs_aw = axi_seq_item::type_id::create("hs_aw");
                hs_aw.handshake = 1'b1;
                hs_aw.wr_rd     = 1'b1;
                hs_aw.AWID      = intf.AWID;
                hs_aw.AWADDR    = intf.AWADDR;
                handshake_port.write(hs_aw);
            end

            // ---- HANDSHAKE: ARVALID & ARREADY ----
            if (intf.ARVALID && intf.ARREADY) begin
                axi_seq_item hs_ar = axi_seq_item::type_id::create("hs_ar");
                hs_ar.handshake = 1'b1;
                hs_ar.wr_rd     = 1'b0;
                hs_ar.ARID      = intf.ARID;
                hs_ar.ARADDR    = intf.ARADDR;
                handshake_port.write(hs_ar);
            end

            // ---- WRITE TRANSACTION ----
            if (intf.AWVALID && intf.AWREADY) begin
                axi_seq_item write_item = axi_seq_item::type_id::create("write_item");

                write_item.wr_rd   = 1'b1;
                write_item.AWID    = intf.AWID;
                write_item.AWADDR  = intf.AWADDR;
                write_item.AWLEN   = intf.AWLEN;
                write_item.AWSIZE  = intf.AWSIZE;
                write_item.AWBURST = intf.AWBURST;

                // Capture write data beats
                for (int i = 0; i <= intf.AWLEN; i++) begin
                    @(posedge intf.CLK);
                    wait (intf.WVALID && intf.WREADY);

                    write_item.WDATA.push_back(intf.WDATA);
                    write_item.WSTRB = intf.WSTRB;
                    write_item.WLAST = intf.WLAST;

                    if (intf.WLAST) break;
                end

                // Capture write response
                @(posedge intf.CLK);
                wait (intf.BVALID && intf.BREADY);
                write_item.BRESP = intf.BRESP;
                write_item.BID   = intf.BID;

                // Send to scoreboard
                wr_analysis_port.write(write_item);
            end

            // ---- READ TRANSACTION ----
            if (intf.ARVALID && intf.ARREADY) begin
                axi_seq_item read_item = axi_seq_item::type_id::create("read_item");

                read_item.wr_rd   = 1'b0;
                read_item.ARID    = intf.ARID;
                read_item.ARADDR  = intf.ARADDR;
                read_item.ARLEN   = intf.ARLEN;
                read_item.ARSIZE  = intf.ARSIZE;
                read_item.ARBURST = intf.ARBURST;

                // Capture read data beats
                for (int i = 0; i <= intf.ARLEN; i++) begin
                    @(posedge intf.CLK);
                    wait (intf.RVALID && intf.RREADY);

                    read_item.RDATA = intf.RDATA;
                    read_item.RRESP = intf.RRESP;
                    read_item.RLAST = intf.RLAST;

                    if (intf.RLAST) break;
                end

                // Send to scoreboard
                rd_analysis_port.write(read_item);
            end
        end
    endtask
endclass

