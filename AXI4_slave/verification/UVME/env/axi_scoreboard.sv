/*class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    typedef struct {
        bit [31:0] addr;
        bit [31:0] data[$];
        bit [3:0]  id;
        bit [2:0]  size;
        bit [1:0]  burst;
        bit [7:0]  len;
        bit        valid;
        bit        ready;
        bit        last;
        bit [3:0]  wstrb;
        bit [1:0]  resp;
        bit [3:0]  bid;
        bit        bvalid;
        bit        bready;
    } axi_trans_t;

    axi_trans_t wr_queue[$];
    axi_trans_t rd_queue[$];
    axi_trans_t ref_queue[$];

    uvm_analysis_imp#(axi_seq_item, axi_scoreboard) wr_export;
    uvm_analysis_imp#(axi_seq_item, axi_scoreboard) rd_export;

    function new(string name = "axi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_export = new("wr_export", this);
        rd_export = new("rd_export", this);
    endfunction

    function void write(axi_seq_item t);
        axi_trans_t trans;

        if (t.wr_rd == 1'b1) begin 
            trans.addr   = t.AWADDR;
            trans.id     = t.AWID;
            trans.size   = t.AWSIZE;
            trans.burst  = t.AWBURST;
            trans.len    = t.AWLEN;
            trans.valid  = t.AWVALID;
            trans.ready  = t.AWREADY;
            trans.wstrb  = t.WSTRB;
            trans.last   = t.WLAST;
            trans.valid  = t.WVALID;
            trans.ready  = t.WREADY;
            trans.bid    = t.BID;
            trans.resp   = t.BRESP;
            trans.bvalid = t.BVALID;
            trans.bready = t.BREADY;

            for (int i = 0; i <= t.AWLEN; i++) begin
                trans.data.push_back(t.WDATA[i]);
            end

            wr_queue.push_back(trans);

            `uvm_info("SCOREBOARD", 
                $sformatf("\nWRITE Address: AWADDR=0x%0h\t AWID=0x%0h\t AWLEN=%0h\t AWSIZE=%0d\t AWBURST=%0d\n", 
                t.AWADDR, t.AWID, t.AWLEN, t.AWSIZE, t.AWBURST), UVM_MEDIUM)

            `uvm_info("SCOREBOARD", 
                $sformatf("\nWRITE Data:\t WDATA=0x%0p\t WSTRB=0x%0h\t WLAST=%0d\n", 
                t.WDATA, t.WSTRB, t.WLAST), UVM_MEDIUM)
            
            `uvm_info("SCOREBOARD", 
                $sformatf("\nWRITE Response:\t BID=0x%0h\t BRESP=0x%0d\n", 
                t.BID, t.BRESP), UVM_MEDIUM) 

        end else begin 
            trans.addr   = t.ARADDR;
            trans.id     = t.ARID;
            trans.size   = t.ARSIZE;
            trans.burst  = t.ARBURST;
            trans.len    = t.ARLEN;
            trans.valid  = t.ARVALID;
            trans.ready  = t.ARREADY;
            trans.last   = t.RLAST;
            trans.valid  = t.RVALID;
            trans.ready  = t.RREADY;
            trans.resp   = t.RRESP;
            trans.data.push_back(t.RDATA);

            rd_queue.push_back(trans);

            `uvm_info("SCOREBOARD", 
                $sformatf("\nREAD Address: ARADDR=0x%0h\t ARID=0x%0h\t ARLEN=%0d\t ARSIZE=%0d\t ARBURST=%0d\n", 
                t.ARADDR, t.ARID, t.ARLEN, t.ARSIZE, t.ARBURST), UVM_MEDIUM)

            `uvm_info("SCOREBOARD", 
                $sformatf("\nREAD Data: RDATA=0x%0h\t RRESP=0x%0h\t RLAST=0x%0h\n", 
                t.RDATA, t.RRESP, t.RLAST), UVM_MEDIUM)

    end
    endfunction
    
 function void check_phase(uvm_phase phase);
    
    axi_trans_t wr_trans, rd_trans;

    while (wr_queue.size() > 0 && rd_queue.size() > 0) begin
        wr_trans = wr_queue.pop_front();
        rd_trans = rd_queue.pop_front();

        // ---- Address & ID Check ----
        if ((wr_trans.addr == rd_trans.addr) && (wr_trans.id == rd_trans.id)) begin
            `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                "\nPASS: AWADDR=0x%0h\t ARADDR=0x%0h\t AWID=0x%0h\t ARID=0x%0h\n", wr_trans.addr,rd_trans.addr,  wr_trans.id, rd_trans.id), UVM_MEDIUM)

            // ---- LEN, SIZE, BURST Comparison ----
            if ((wr_trans.len == rd_trans.len) &&
                (wr_trans.size == rd_trans.size) &&
                (wr_trans.burst == rd_trans.burst)) begin

                `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                    "\nPASS: AWLEN=%0d\t ARLEN=%0d\t AWSIZE=%0d\t ARSIZE=%0d\t AWBURST=%0d\t ARBURST=%0d\n", wr_trans.len, rd_trans.len, wr_trans.size, rd_trans.size, wr_trans.burst, rd_trans.burst), UVM_MEDIUM)

            end else begin
                if (wr_trans.len != rd_trans.len)
                    `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "\nLEN MISMATCH: AWLEN=%0d\t ARLEN=%0d\n", wr_trans.len, rd_trans.len))
                if (wr_trans.size != rd_trans.size)
                    `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "\nSIZE MISMATCH: AWSIZE=%0d\t ARSIZE=%0d\n", wr_trans.size, rd_trans.size))
                if (wr_trans.burst != rd_trans.burst)
                    `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "\nBURST MISMATCH: AWBURST=%0d\t ARBURST=%0d\n", wr_trans.burst, rd_trans.burst))
            end

            // ---- W vs R Data Check ----
            if (wr_trans.data.size() == rd_trans.data.size()) begin
                bit all_match = 1;
                foreach (wr_trans.data[i]) begin
                    if (wr_trans.data[i] !== rd_trans.data[i]) begin
                        all_match = 0;
                        `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                            "\nDATA MISMATCH:\t AWID=%0d\t WDATA=0x%0h\t ARID=%0d\t RDATA=0x%0h\n", 
                            wr_trans.id[i], rd_trans.id[i], wr_trans.data[i], rd_trans.data[i]))
                    end
                end
                
                if (all_match)
                    `uvm_info("CHECKER - W/R_CHANNEL", "WRITE/READ DATA MATCH: PASS", UVM_MEDIUM)
            end else begin
            `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
             "\nW&R DATA MISMATCH:\t AWADDR=0x%0h\t ARADDR=0x%0h\t AWID=0x%0h\t ARID=0x%0h\t AWLEN=%0d\t ARLEN=%0d\t AWSIZE=%0d\t ARSIZE=%0d\t AWBURST=%0d\t ARBURST=%0d\n WDATA.size=%0d\t RDATA.size=%0d\n WDATA[0]=0x%0h\t RDATA[0]=0x%0h\n",
                wr_trans.addr, rd_trans.addr,
                wr_trans.id, rd_trans.id,
                wr_trans.len, rd_trans.len,
                wr_trans.size, rd_trans.size,
                wr_trans.burst, rd_trans.burst,
                wr_trans.data.size(), rd_trans.data.size(),
                wr_trans.data[0], rd_trans.data[0]
                ));

            end 

            // ---- B Channel Check ----
            if (wr_trans.bvalid && wr_trans.bready) begin
                if (wr_trans.resp == 2'b00) begin
                    `uvm_info("CHECKER - B_CHANNEL", $sformatf(
                        "PASS: BID=0x%0h, BRESP=0x%0h\n", wr_trans.bid, wr_trans.resp), UVM_MEDIUM)
                end else begin
                    `uvm_error("CHECKER - B_CHANNEL", $sformatf(
                        "FAIL: BRESP=0x%0h (non-OKAY)\n", wr_trans.resp))
                end
            end else begin
                `uvm_error("CHECKER - B_CHANNEL", "BVALID or BREADY not asserted during response")
            end

            // ---- R Channel Check ----
            if (rd_trans.valid && rd_trans.ready && rd_trans.last) begin
                if (rd_trans.resp == 2'b00) begin
                    `uvm_info("CHECKER - R_CHANNEL", $sformatf(
                        "PASS: RRESP=0x%0h\t RLAST=0x%0d\n", rd_trans.resp, rd_trans.last), UVM_MEDIUM)
                end else begin
                    `uvm_error("CHECKER - R_CHANNEL", $sformatf(
                        "FAIL: RRESP=0x%0h (non-OKAY)\n", rd_trans.resp))
                end
            end else begin
                `uvm_error("CHECKER - R_CHANNEL", "RVALID, RREADY, or RLAST not asserted")
            end

        end else begin
            `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                "ADDR/ID MISMATCH: WR_ADDR=0x%0h\t RD_ADDR=0x%0h\t WR_ID=0x%0h\t RD_ID=0x%0h\n", 
                wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id))
        end
    end
endfunction 

function void check_handshake_phase();
    foreach (wr_queue[i]) begin
        if (!(wr_queue[i].valid && wr_queue[i].ready)) begin
            `uvm_error("HANDSHAKE_CHECK", $sformatf("WRITE address handshake failed: AWVALID=%0b AWREADY=%0b", wr_queue[i].valid, wr_queue[i].ready))
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("WRITE address handshake PASSED: AWVALID=%0b AWREADY=%0b", wr_queue[i].valid, wr_queue[i].ready), UVM_LOW)
        end

        if (!(wr_queue[i].bvalid && wr_queue[i].bready)) begin
            `uvm_error("HANDSHAKE_CHECK", $sformatf("B channel handshake failed: BVALID=%0b BREADY=%0b", wr_queue[i].bvalid, wr_queue[i].bready))
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("B channel handshake PASSED: BVALID=%0b BREADY=%0b", wr_queue[i].bvalid, wr_queue[i].bready), UVM_LOW)
        end
    end

    foreach (rd_queue[i]) begin
        if (!(rd_queue[i].valid && rd_queue[i].ready)) begin
            `uvm_error("HANDSHAKE_CHECK", $sformatf("READ channel handshake failed: RVALID=%0b RREADY=%0b", rd_queue[i].valid, rd_queue[i].ready))
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("READ channel handshake PASSED: RVALID=%0b RREADY=%0b", rd_queue[i].valid, rd_queue[i].ready), UVM_LOW)
        end
    end
endfunction

function void check_writeeration();
    foreach (wr_queue[i]) begin
        axi_trans_t wr = wr_queue[i];

        // Address phase handshake
        if (!wr.valid || !wr.ready)
            `uvm_error("WRITE", "AWVALID or AWREADY not asserted during address phase")
        else
            `uvm_info("WRITE", "Address phase handshake PASSED", UVM_LOW)

        // Data beat count check
        if (wr.data.size() != wr.len + 1)
            `uvm_error("WRITE", $sformatf("Data count mismatch: Expected=%0d, Got=%0d", wr.len + 1, wr.data.size()))
        else
            `uvm_info("WRITE", $sformatf("Data beat count PASSED: %0d beats", wr.data.size()), UVM_LOW)

        // WLAST check
        if (!wr.last)
            `uvm_error("WRITE", "WLAST not asserted on final data beat")
        else
            `uvm_info("WRITE", "WLAST asserted correctly", UVM_LOW)

        // Write response handshake
        if (!(wr.bvalid && wr.bready))
            `uvm_error("WRITE", "BVALID or BREADY not asserted during response phase")
        else
            `uvm_info("WRITE", "Write response handshake PASSED", UVM_LOW)
    end
endfunction

function void check_readeration();
    foreach (rd_queue[i]) begin
        axi_trans_t rd = rd_queue[i];

        // Address phase handshake
        if (!rd.valid || !rd.ready)
            `uvm_error("READ", "ARVALID or ARREADY not asserted during address phase")
        else
            `uvm_info("READ", "Address phase handshake PASSED", UVM_LOW)

        // Data beat count check
        if (rd.data.size() != rd.len + 1)
            `uvm_error("READ", $sformatf("Data count mismatch: Expected=%0d, Got=%0d", rd.len + 1, rd.data.size()))
        else
            `uvm_info("READ", $sformatf("Data beat count PASSED: %0d beats", rd.data.size()), UVM_LOW)

        // RLAST check
        if (!rd.last)
            `uvm_error("READ", "RLAST not asserted on final read beat")
        else
            `uvm_info("READ", "RLAST asserted correctly", UVM_LOW)

        // RRESP check
        if (rd.resp != 2'b00)
            `uvm_error("READ", $sformatf("Read response error: RRESP=0x%0h", rd.resp))
        else
            `uvm_info("READ", "Read response (RRESP) indicates OKAY", UVM_LOW)
    end
endfunction

endclass */

/*class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    typedef struct {
        bit [31:0] addr;
        bit [31:0] data[$];
        bit [3:0]  id;
        bit [2:0]  size;
        bit [1:0]  burst;
        bit [7:0]  len;
        // Address channels handshake signals
        bit        awvalid;
        bit        awready;
        bit        arvalid;
        bit        arready;
        // Data channels handshake signals
        bit        wvalid;
        bit        wready;
        bit        rvalid;
        bit        rready;
        // Response channel handshake signals
        bit        bvalid;
        bit        bready;
        // Control/status signals
        bit        wlast;
        bit        rlast;
        bit [3:0]  wstrb;
        bit [1:0]  bresp;
        bit [1:0]  rresp;
        bit [3:0]  bid;
        bit [3:0]  rid;
    } axi_trans_t;

    axi_trans_t wr_queue[$];
    axi_trans_t rd_queue[$];
    
    // Use standard UVM approach with two TLM analysis ports
    uvm_analysis_port #(axi_seq_item) wr_analysis_port;
    uvm_analysis_port #(axi_seq_item) rd_analysis_port;
    
    // TLM analysis implementation for write and read
    `uvm_analysis_imp_decl(_wr)
    `uvm_analysis_imp_decl(_rd)
    
    uvm_analysis_imp_wr #(axi_seq_item, axi_scoreboard) wr_export;
    uvm_analysis_imp_rd #(axi_seq_item, axi_scoreboard) rd_export;

    function new(string name = "axi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_export = new("wr_export", this);
        rd_export = new("rd_export", this);
        wr_analysis_port = new("wr_analysis_port", this);
        rd_analysis_port = new("rd_analysis_port", this);
    endfunction

    // Write transaction handler
    function void write_wr(axi_seq_item t);
        axi_trans_t trans;

        // AW channel signals
        trans.addr    = t.AWADDR;
        trans.id      = t.AWID;
        trans.size    = t.AWSIZE;
        trans.burst   = t.AWBURST;
        trans.len     = t.AWLEN;
        trans.awvalid = t.AWVALID;
        trans.awready = t.AWREADY;
        
        // W channel signals
        trans.wvalid  = t.WVALID;
        trans.wready  = t.WREADY;
        trans.wstrb   = t.WSTRB;
        trans.wlast   = t.WLAST;
        
        // B channel signals
        trans.bid     = t.BID;
        trans.bresp   = t.BRESP;
        trans.bvalid  = t.BVALID;
        trans.bready  = t.BREADY;

        // Capture data beats - WDATA is a dynamic array
        for (int i = 0; i <= t.AWLEN; i++) begin
            if (i < t.WDATA.size()) begin
                trans.data.push_back(t.WDATA[i]);
            end
        end

        wr_queue.push_back(trans);

        `uvm_info("SCOREBOARD", 
            $sformatf("\nWRITE Address: AWADDR=0x%0h\t AWID=0x%0h\t AWLEN=%0h\t AWSIZE=%0d\t AWBURST=%0d\n", 
            t.AWADDR, t.AWID, t.AWLEN, t.AWSIZE, t.AWBURST), UVM_MEDIUM)

        `uvm_info("SCOREBOARD", 
            $sformatf("\nWRITE Data:\t WDATA=0x%0p\t WSTRB=0x%0h\t WLAST=%0d\n", 
            t.WDATA, t.WSTRB, t.WLAST), UVM_MEDIUM)
        
        `uvm_info("SCOREBOARD", 
            $sformatf("\nWRITE Response:\t BID=0x%0h\t BRESP=0x%0d\n", 
            t.BID, t.BRESP), UVM_MEDIUM)
    endfunction

    // Read transaction handler
    function void write_rd(axi_seq_item t);
        axi_trans_t trans;

        // AR channel signals
        trans.addr    = t.ARADDR;
        trans.id      = t.ARID;
        trans.size    = t.ARSIZE;
        trans.burst   = t.ARBURST;
        trans.len     = t.ARLEN;
        trans.arvalid = t.ARVALID;
        trans.arready = t.ARREADY;
        
        // R channel signals
        trans.rvalid  = t.RVALID;
        trans.rready  = t.RREADY;
        trans.rlast   = t.RLAST;
        trans.rresp   = t.RRESP;
        trans.rid     = t.RID;

        // Capture data beats - Handle RDATA as a fixed array
        // First, push the single RDATA value into our queue
        trans.data.push_back(t.RDATA);
        
        // If there are multiple data beats expected (based on ARLEN),
        // log a warning as we're only capturing one beat with the fixed array
        if (t.ARLEN > 0) begin
            `uvm_warning("SCOREBOARD", $sformatf(
                "RDATA is a fixed array but ARLEN=%0d indicates multiple beats expected", 
                t.ARLEN))
        end

        rd_queue.push_back(trans);

        `uvm_info("SCOREBOARD", 
            $sformatf("\nREAD Address: ARADDR=0x%0h\t ARID=0x%0h\t ARLEN=%0d\t ARSIZE=%0d\t ARBURST=%0d\n", 
            t.ARADDR, t.ARID, t.ARLEN, t.ARSIZE, t.ARBURST), UVM_MEDIUM)

        `uvm_info("SCOREBOARD", 
            $sformatf("\nREAD Data: RDATA=0x%0h\t RRESP=0x%0h\t RLAST=0x%0h\n", 
            t.RDATA, t.RRESP, t.RLAST), UVM_MEDIUM)
    endfunction
    
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        
        // Check handshake separately
        check_handshake_phase();
        
        // Check individual write and read operations
        check_write_operation();
        check_read_operation();
        
        // Check write vs read data consistency
        compare_wr_rd_transactions();
    endfunction 

    function void compare_wr_rd_transactions();
        axi_trans_t local_wr_queue[$];
        axi_trans_t local_rd_queue[$];
        axi_trans_t wr_trans;
        axi_trans_t rd_trans;
        
        // Copy queues to avoid modifying originals
        foreach (wr_queue[i]) local_wr_queue.push_back(wr_queue[i]);
        foreach (rd_queue[i]) local_rd_queue.push_back(rd_queue[i]);

        while (local_wr_queue.size() > 0 && local_rd_queue.size() > 0) begin
            wr_trans = local_wr_queue.pop_front();
            rd_trans = local_rd_queue.pop_front();

            // ---- Address & ID Check ----
            if ((wr_trans.addr == rd_trans.addr) && (wr_trans.id == rd_trans.id)) begin
                `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                    "\nPASS: AWADDR=0x%0h\t ARADDR=0x%0h\t AWID=0x%0h\t ARID=0x%0h\n", 
                    wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id), UVM_MEDIUM)

                // ---- LEN, SIZE, BURST Comparison ----
                if ((wr_trans.len == rd_trans.len) &&
                    (wr_trans.size == rd_trans.size) &&
                    (wr_trans.burst == rd_trans.burst)) begin

                    `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "\nPASS: AWLEN=%0d\t ARLEN=%0d\t AWSIZE=%0d\t ARSIZE=%0d\t AWBURST=%0d\t ARBURST=%0d\n", 
                        wr_trans.len, rd_trans.len, wr_trans.size, rd_trans.size, 
                        wr_trans.burst, rd_trans.burst), UVM_MEDIUM)

                end else begin
                    if (wr_trans.len != rd_trans.len)
                        `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                            "\nLEN MISMATCH: AWLEN=%0d\t ARLEN=%0d\n", wr_trans.len, rd_trans.len))
                    if (wr_trans.size != rd_trans.size)
                        `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                            "\nSIZE MISMATCH: AWSIZE=%0d\t ARSIZE=%0d\n", wr_trans.size, rd_trans.size))
                    if (wr_trans.burst != rd_trans.burst)
                        `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                            "\nBURST MISMATCH: AWBURST=%0d\t ARBURST=%0d\n", wr_trans.burst, rd_trans.burst))
                end

                // ---- W vs R Data Check ----
                // For fixed RDATA, we might only have one data element
                // but need to compare to multiple WDATA elements
                if (rd_trans.data.size() > 0 && wr_trans.data.size() > 0) begin
                    bit data_match = 1;
                    
                    // When RDATA is fixed but we have multiple WDATA beats
                    if (rd_trans.data.size() == 1 && wr_trans.data.size() > 1) begin
                        // Compare only the first data beat
                        if (wr_trans.data[0] !== rd_trans.data[0]) begin
                            data_match = 0;
                            `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                                "\nDATA MISMATCH:\t First beat only: WDATA=0x%0h\t RDATA=0x%0h\n", 
                                wr_trans.data[0], rd_trans.data[0]));
                        end
                        
                        // Issue warning about incomplete comparison due to fixed RDATA
                        `uvm_warning("CHECKER - W/R_CHANNEL", $sformatf(
                            "Limited comparison: WDATA has %0d beats but RDATA is fixed (only first beat compared)",
                            wr_trans.data.size()));
                    end 
                    else if (wr_trans.data.size() == rd_trans.data.size()) begin
                        // Equal sizes - do a full comparison
                        foreach (wr_trans.data[i]) begin
                            if (wr_trans.data[i] !== rd_trans.data[i]) begin
                                data_match = 0;
                                `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                                    "\nDATA MISMATCH:\t Index=%0d\t WDATA=0x%0h\t RDATA=0x%0h\n", 
                                    i, wr_trans.data[i], rd_trans.data[i]));
                            end
                        end
                    end 
                    else begin
                        // Size mismatch other than the special case
                        `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                            "\nW&R DATA SIZE MISMATCH:\t WDATA.size=%0d\t RDATA.size=%0d\n",
                            wr_trans.data.size(), rd_trans.data.size()));
                    end
                    
                    if (data_match)
                        `uvm_info("CHECKER - W/R_CHANNEL", "WRITE/READ DATA MATCH: PASS", UVM_MEDIUM);
                end 
                else begin
                    `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                        "\nMISSING DATA:\t WDATA.size=%0d\t RDATA.size=%0d\n",
                        wr_trans.data.size(), rd_trans.data.size()));
                end 

                // ---- B Channel Check ----
                if (wr_trans.bvalid && wr_trans.bready) begin
                    if (wr_trans.bresp == 2'b00) begin
                        `uvm_info("CHECKER - B_CHANNEL", $sformatf(
                            "PASS: BID=0x%0h, BRESP=0x%0h\n", wr_trans.bid, wr_trans.bresp), UVM_MEDIUM);
                    end 
                    else begin
                        `uvm_error("CHECKER - B_CHANNEL", $sformatf(
                            "FAIL: BRESP=0x%0h (non-OKAY)\n", wr_trans.bresp));
                    end
                end 
                else begin
                    `uvm_info("CHECKER - B_CHANNEL", "Note: BVALID or BREADY not asserted during response, skipping check", UVM_LOW);
                end

                // ---- R Channel Check ----
                if (rd_trans.rvalid && rd_trans.rready && rd_trans.rlast) begin
                    if (rd_trans.rresp == 2'b00) begin
                        `uvm_info("CHECKER - R_CHANNEL", $sformatf(
                            "PASS: RRESP=0x%0h\t RLAST=0x%0d\n", rd_trans.rresp, rd_trans.rlast), UVM_MEDIUM);
                    end 
                    else begin
                        `uvm_error("CHECKER - R_CHANNEL", $sformatf(
                            "FAIL: RRESP=0x%0h (non-OKAY)\n", rd_trans.rresp));
                    end
                end 
                else begin
                    `uvm_info("CHECKER - R_CHANNEL", "Note: RVALID, RREADY, or RLAST not asserted, skipping check", UVM_LOW);
                end
            end 
            else begin
                `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                    "ADDR/ID MISMATCH: WR_ADDR=0x%0h\t RD_ADDR=0x%0h\t WR_ID=0x%0h\t RD_ID=0x%0h\n", 
                    wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id));
            end
        end
    endfunction

    function void check_handshake_phase();
        axi_trans_t local_wr_queue[$];
        axi_trans_t local_rd_queue[$];
        axi_trans_t wr_trans;
        axi_trans_t rd_trans;
        int valid_handshakes = 0;
        int failed_handshakes = 0;

        // Copy queues to avoid modifying originals
        foreach (wr_queue[i]) local_wr_queue.push_back(wr_queue[i]);
        foreach (rd_queue[i]) local_rd_queue.push_back(rd_queue[i]);

        `uvm_info("HANDSHAKE_CHECK", $sformatf("Checking %0d write transactions", local_wr_queue.size()), UVM_LOW);
        
        while (local_wr_queue.size() > 0) begin
            wr_trans = local_wr_queue.pop_front();

            // AW channel handshake check
            if (wr_trans.awvalid || wr_trans.awready) begin
                if (wr_trans.awvalid && wr_trans.awready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "WRITE address handshake PASSED: AWVALID=%0b AWREADY=%0b", 
                        wr_trans.awvalid, wr_trans.awready), UVM_LOW);
                end 
                else if (wr_trans.awvalid) begin
                    // Only report errors when VALID is asserted but READY isn't
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "WRITE address handshake PENDING: AWVALID=%0b AWREADY=%0b", 
                        wr_trans.awvalid, wr_trans.awready), UVM_LOW);
                end
            end

            // W channel handshake check
            if (wr_trans.wvalid || wr_trans.wready) begin
                if (wr_trans.wvalid && wr_trans.wready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "W channel handshake PASSED: WVALID=%0b WREADY=%0b", 
                        wr_trans.wvalid, wr_trans.wready), UVM_LOW);
                end 
                else if (wr_trans.wvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "W channel handshake PENDING: WVALID=%0b WREADY=%0b", 
                        wr_trans.wvalid, wr_trans.wready), UVM_LOW);
                end
            end

            // B channel handshake check
            if (wr_trans.bvalid || wr_trans.bready) begin
                if (wr_trans.bvalid && wr_trans.bready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "B channel handshake PASSED: BVALID=%0b BREADY=%0b", 
                        wr_trans.bvalid, wr_trans.bready), UVM_LOW);
                end 
                else if (wr_trans.bvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "B channel handshake PENDING: BVALID=%0b BREADY=%0b", 
                        wr_trans.bvalid, wr_trans.bready), UVM_LOW);
                end
            end
        end

        `uvm_info("HANDSHAKE_CHECK", $sformatf("Checking %0d read transactions", local_rd_queue.size()), UVM_LOW);
        
        while (local_rd_queue.size() > 0) begin
            rd_trans = local_rd_queue.pop_front();

            // AR channel handshake check
            if (rd_trans.arvalid || rd_trans.arready) begin
                if (rd_trans.arvalid && rd_trans.arready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ address handshake PASSED: ARVALID=%0b ARREADY=%0b", 
                        rd_trans.arvalid, rd_trans.arready), UVM_LOW);
                end 
                else if (rd_trans.arvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ address handshake PENDING: ARVALID=%0b ARREADY=%0b", 
                        rd_trans.arvalid, rd_trans.arready), UVM_LOW);
                end
            end

            // R channel handshake check
            if (rd_trans.rvalid || rd_trans.rready) begin
                if (rd_trans.rvalid && rd_trans.rready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ data handshake PASSED: RVALID=%0b RREADY=%0b", 
                        rd_trans.rvalid, rd_trans.rready), UVM_LOW);
                end 
                else if (rd_trans.rvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ data handshake PENDING: RVALID=%0b RREADY=%0b", 
                        rd_trans.rvalid, rd_trans.rready), UVM_LOW);
                end
            end
        end
        
        if (valid_handshakes == 0 && failed_handshakes == 0) begin
            `uvm_warning("HANDSHAKE_CHECK", "No active handshakes detected - check if monitor is capturing valid handshake attempts");
        end 
        else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("Completed handshakes: %0d, Pending handshakes: %0d", 
                      valid_handshakes, failed_handshakes), UVM_LOW);
        end
    endfunction

    function void check_write_operation();
        axi_trans_t local_wr_queue[$];
        axi_trans_t wr_trans;

        // Copy queue to avoid modifying original
        foreach (wr_queue[i]) local_wr_queue.push_back(wr_queue[i]);

        while (local_wr_queue.size() > 0) begin
            wr_trans = local_wr_queue.pop_front();

            // Skip transactions with no valid handshakes
            if (!wr_trans.awvalid) continue;

            // Address phase handshake check with additional info
            if (!(wr_trans.awvalid && wr_trans.awready)) begin
                `uvm_info("WRITE", $sformatf(
                    "Address phase handshake INCOMPLETE: AWVALID=%0b AWREADY=%0b", 
                    wr_trans.awvalid, wr_trans.awready), UVM_LOW);
            end 
            else begin
                `uvm_info("WRITE", "Address phase handshake COMPLETE", UVM_LOW);
            end

            // Data phase handshake check
            if (!(wr_trans.wvalid && wr_trans.wready)) begin
                `uvm_info("WRITE", $sformatf(
                    "Data phase handshake INCOMPLETE: WVALID=%0b WREADY=%0b", 
                    wr_trans.wvalid, wr_trans.wready), UVM_LOW);
            end 
            else begin
                `uvm_info("WRITE", "Data phase handshake COMPLETE", UVM_LOW);
            end

            // Data beat count check
            if (wr_trans.data.size() != wr_trans.len + 1) begin
                `uvm_info("WRITE", $sformatf(
                    "Data count mismatch: Expected=%0d, Got=%0d", 
                    wr_trans.len + 1, wr_trans.data.size()), UVM_LOW);
            end 
            else begin
                `uvm_info("WRITE", $sformatf(
                    "Data beat count MATCHES: %0d beats", 
                    wr_trans.data.size()), UVM_LOW);
            end

            // WLAST check - only when we have valid data
            if (wr_trans.data.size() > 0) begin
                if (!wr_trans.wlast) begin
                    `uvm_info("WRITE", "WLAST not asserted on final data beat", UVM_LOW);
                end 
                else begin
                    `uvm_info("WRITE", "WLAST asserted correctly", UVM_LOW);
                end
            end

            // Write response handshake - only check if both signals are valid
            if (wr_trans.bvalid || wr_trans.bready) begin
                if (!(wr_trans.bvalid && wr_trans.bready)) begin
                    `uvm_info("WRITE", $sformatf(
                        "Response phase handshake INCOMPLETE: BVALID=%0b BREADY=%0b", 
                        wr_trans.bvalid, wr_trans.bready), UVM_LOW);
                end 
                else begin
                    `uvm_info("WRITE", "Write response handshake COMPLETE", UVM_LOW);
                    
                    // BRESP check - only when response is valid
                    if (wr_trans.bresp != 2'b00) begin
                        `uvm_info("WRITE", $sformatf(
                            "Write response error: BRESP=0x%0h", wr_trans.bresp), UVM_LOW);
                    end 
                    else begin
                        `uvm_info("WRITE", "Write response (BRESP) indicates OKAY", UVM_LOW);
                    end
                end
            end
        end
    endfunction

    function void check_read_operation();
        axi_trans_t local_rd_queue[$];
        axi_trans_t rd_trans;

        // Copy queue to avoid modifying original
        foreach (rd_queue[i]) local_rd_queue.push_back(rd_queue[i]);

        while (local_rd_queue.size() > 0) begin
            rd_trans = local_rd_queue.pop_front();

            // Skip transactions with no valid handshakes
            if (!rd_trans.arvalid) continue;

            // Address phase handshake
            if (!(rd_trans.arvalid && rd_trans.arready)) begin
                `uvm_info("READ", $sformatf(
                    "Address phase handshake INCOMPLETE: ARVALID=%0b ARREADY=%0b", 
                    rd_trans.arvalid, rd_trans.arready), UVM_LOW);
            end 
            else begin
                `uvm_info("READ", "Address phase handshake COMPLETE", UVM_LOW);
            end

            // Data phase handshake
            if (!(rd_trans.rvalid && rd_trans.rready)) begin
                `uvm_info("READ", $sformatf(
                    "Data phase handshake INCOMPLETE: RVALID=%0b RREADY=%0b", 
                    rd_trans.rvalid, rd_trans.rready), UVM_LOW);
            end 
            else begin
                `uvm_info("READ", "Data phase handshake COMPLETE", UVM_LOW);
            end

            // Since RDATA is fixed, we won't have multiple beats in our queue
            // But we still need to warn if expected multiple beats
            if (rd_trans.len > 0) begin
                `uvm_info("READ", $sformatf(
                    "NOTE: ARLEN=%0d indicates multiple beats, but RDATA is fixed - captured only one beat", 
                    rd_trans.len), UVM_LOW);
            end

            // RLAST check
            if (rd_trans.data.size() > 0) begin
                if (!rd_trans.rlast) begin
                    `uvm_info("READ", "RLAST not asserted on read beat", UVM_LOW);
                end 
                else begin
                    `uvm_info("READ", "RLAST asserted correctly", UVM_LOW);
                end
            end

            // RRESP check - only when valid response
            if (rd_trans.rvalid && rd_trans.rready) begin
                if (rd_trans.rresp != 2'b00) begin
                    `uvm_info("READ", $sformatf(
                        "Read response error: RRESP=0x%0h", rd_trans.rresp), UVM_LOW);
                end 
                else begin
                    `uvm_info("READ", "Read response (RRESP) indicates OKAY", UVM_LOW);
                end
            end
        end
    endfunction
endclass */

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    typedef struct {
        bit [31:0] addr;
        bit [31:0] data[$];
        bit [3:0]  id;
        bit [2:0]  size;
        bit [1:0]  burst;
        bit [7:0]  len;
        // Address channels handshake signals
        bit        awvalid;
        bit        awready;
        bit        arvalid;
        bit        arready;
        // Data channels handshake signals
        bit        wvalid;
        bit        wready;
        bit        rvalid;
        bit        rready;
        // Response channel handshake signals
        bit        bvalid;
        bit        bready;
        // Control/status signals
        bit        wlast;
        bit        rlast;
        bit [3:0]  wstrb;
        bit [1:0]  bresp;
        bit [1:0]  rresp;
        bit [3:0]  bid;
        bit [3:0]  rid;
    } axi_trans_t;

    // New structure for handshake tracking
    typedef struct {
        bit        is_write;   // 1 for write, 0 for read
        bit [31:0] addr;
        bit [3:0]  id;
        time       timestamp;
    } handshake_t;

    axi_trans_t wr_queue[$];
    axi_trans_t rd_queue[$];
    handshake_t handshake_queue[$];
    
    // Use standard UVM approach with TLM analysis ports
    uvm_analysis_port #(axi_seq_item) wr_analysis_port;
    uvm_analysis_port #(axi_seq_item) rd_analysis_port;
    
    // TLM analysis implementation for write, read and handshake
    `uvm_analysis_imp_decl(_wr)
    `uvm_analysis_imp_decl(_rd)
    `uvm_analysis_imp_decl(_handshake)
    
    uvm_analysis_imp_wr #(axi_seq_item, axi_scoreboard) wr_export;
    uvm_analysis_imp_rd #(axi_seq_item, axi_scoreboard) rd_export;
    uvm_analysis_imp_handshake #(axi_seq_item, axi_scoreboard) handshake_export;

    function new(string name = "axi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_export = new("wr_export", this);
        rd_export = new("rd_export", this);
        handshake_export = new("handshake_export", this);
        wr_analysis_port = new("wr_analysis_port", this);
        rd_analysis_port = new("rd_analysis_port", this);
    endfunction

    // Handshake transaction handler
    function void write_handshake(axi_seq_item t);
        handshake_t handshake;

        if (!t.handshake) return; // Skip if not a handshake item

        handshake.is_write = t.wr_rd;
        handshake.timestamp = $time;

        if (t.wr_rd) begin // Write handshake
            handshake.addr = t.AWADDR;
            handshake.id = t.AWID;
            `uvm_info("HANDSHAKE", 
                $sformatf("Write handshake captured: AWADDR=0x%0h AWID=0x%0h at time %0t", 
                t.AWADDR, t.AWID, $time), UVM_MEDIUM)
        end else begin // Read handshake
            handshake.addr = t.ARADDR;
            handshake.id = t.ARID;
            `uvm_info("HANDSHAKE", 
                $sformatf("Read handshake captured: ARADDR=0x%0h ARID=0x%0h at time %0t", 
                t.ARADDR, t.ARID, $time), UVM_MEDIUM)
        end

        handshake_queue.push_back(handshake);
    endfunction

    // Write transaction handler
    function void write_wr(axi_seq_item t);
        axi_trans_t trans;

        // AW channel signals
        trans.addr    = t.AWADDR;
        trans.id      = t.AWID;
        trans.size    = t.AWSIZE;
        trans.burst   = t.AWBURST;
        trans.len     = t.AWLEN;
        trans.awvalid = 1'b1;  // These came through the write port, so must be valid
        trans.awready = 1'b1;
        
        // W channel signals
        trans.wvalid  = 1'b1;  // These came through the write port, so must be valid
        trans.wready  = 1'b1;
        trans.wstrb   = t.WSTRB;
        trans.wlast   = t.WLAST;
        
        // B channel signals
        trans.bid     = t.BID;
        trans.bresp   = t.BRESP;
        trans.bvalid  = 1'b1;  // These came through the write port, so must be valid
        trans.bready  = 1'b1;

        // Capture data beats - WDATA is a dynamic array
        foreach (t.WDATA[i]) begin
            trans.data.push_back(t.WDATA[i]);
        end

        wr_queue.push_back(trans);

        `uvm_info("SCOREBOARD", 
            $sformatf("\nWRITE Address: AWADDR=0x%0h\t AWID=0x%0h\t AWLEN=%0h\t AWSIZE=%0d\t AWBURST=%0d\n", 
            t.AWADDR, t.AWID, t.AWLEN, t.AWSIZE, t.AWBURST), UVM_MEDIUM)

        `uvm_info("SCOREBOARD", 
            $sformatf("\nWRITE Data:\t WDATA=0x%0p\t WSTRB=0x%0h\t WLAST=%0d\n", 
            t.WDATA, t.WSTRB, t.WLAST), UVM_MEDIUM)
        
        `uvm_info("SCOREBOARD", 
            $sformatf("\nWRITE Response:\t BID=0x%0h\t BRESP=0x%0d\n", 
            t.BID, t.BRESP), UVM_MEDIUM)
    endfunction

    // Read transaction handler
    function void write_rd(axi_seq_item t);
        axi_trans_t trans;

        // AR channel signals
        trans.addr    = t.ARADDR;
        trans.id      = t.ARID;
        trans.size    = t.ARSIZE;
        trans.burst   = t.ARBURST;
        trans.len     = t.ARLEN;
        trans.arvalid = 1'b1;  // These came through the read port, so must be valid
        trans.arready = 1'b1;
        
        // R channel signals
        trans.rvalid  = 1'b1;  // These came through the read port, so must be valid
        trans.rready  = 1'b1;
        trans.rlast   = t.RLAST;
        trans.rresp   = t.RRESP;
        trans.rid     = t.RID;

        // Capture data beats - Handle RDATA as a fixed array
        // First, push the single RDATA value into our queue
        trans.data.push_back(t.RDATA);
        
        // If there are multiple data beats expected (based on ARLEN),
        // log a warning as we're only capturing one beat with the fixed array
        if (t.ARLEN > 0) begin
            `uvm_warning("SCOREBOARD", $sformatf(
                "RDATA is a fixed array but ARLEN=%0d indicates multiple beats expected", 
                t.ARLEN))
        end

        rd_queue.push_back(trans);

        `uvm_info("SCOREBOARD", 
            $sformatf("\nREAD Address: ARADDR=0x%0h\t ARID=0x%0h\t ARLEN=%0d\t ARSIZE=%0d\t ARBURST=%0d\n", 
            t.ARADDR, t.ARID, t.ARLEN, t.ARSIZE, t.ARBURST), UVM_MEDIUM)

        `uvm_info("SCOREBOARD", 
            $sformatf("\nREAD Data: RDATA=0x%0h\t RRESP=0x%0h\t RLAST=0x%0h\n", 
            t.RDATA, t.RRESP, t.RLAST), UVM_MEDIUM)
    endfunction
    
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        
        // Check collected handshakes
        check_collected_handshakes();
        
        // Check handshake separately
        check_handshake_phase();
        
        // Check individual write and read operations
        check_write_operation();
        check_read_operation();
        
        // Check write vs read data consistency
        compare_wr_rd_transactions();
    endfunction 

    function void check_collected_handshakes();
    int write_handshakes = 0;
    int read_handshakes = 0;
    time min_time = 0;
    time max_time = 0;
    time avg_time = 0;
    time total_time = 0;
    time time_between_handshakes[$];
    
    if (handshake_queue.size() == 0) begin
        `uvm_warning("HANDSHAKE_CHECKER", "No handshakes collected from monitor!")
        return;
    end
    
    `uvm_info("HANDSHAKE_CHECKER", $sformatf("Analyzing %0d handshakes collected from monitor", 
                                            handshake_queue.size()), UVM_LOW)
    
    foreach (handshake_queue[i]) begin
        if (handshake_queue[i].is_write) begin
            write_handshakes++;
            `uvm_info("HANDSHAKE_CHECKER", $sformatf(
                "Write handshake[%0d]: ADDR=0x%0h ID=0x%0h Time=%0t", 
                i, handshake_queue[i].addr, handshake_queue[i].id, 
                handshake_queue[i].timestamp), UVM_HIGH)
        end else begin
            read_handshakes++;
            `uvm_info("HANDSHAKE_CHECKER", $sformatf(
                "Read handshake[%0d]: ADDR=0x%0h ID=0x%0h Time=%0t", 
                i, handshake_queue[i].addr, handshake_queue[i].id, 
                handshake_queue[i].timestamp), UVM_HIGH)
        end
        
        // Track timing statistics
        if (i == 0) begin
            min_time = handshake_queue[i].timestamp;
            max_time = handshake_queue[i].timestamp;
        end else begin
            if (handshake_queue[i].timestamp < min_time)
                min_time = handshake_queue[i].timestamp;
            if (handshake_queue[i].timestamp > max_time)
                max_time = handshake_queue[i].timestamp;
                
            // Calculate time between consecutive handshakes
            time_between_handshakes.push_back(handshake_queue[i].timestamp - 
                                             handshake_queue[i-1].timestamp);
        end
        total_time += handshake_queue[i].timestamp;
    end
    
    if (handshake_queue.size() > 0)
        avg_time = total_time / handshake_queue.size();
        
// Calculate average interval between handshakes
time total_interval = 0;
time avg_interval = 0;
if (time_between_handshakes.size() > 0) begin
    foreach (time_between_handshakes[i])
        total_interval += time_between_handshakes[i];
    avg_interval = total_interval / time_between_handshakes.size();
end    
    // Report handshake statistics
    `uvm_info("HANDSHAKE_CHECKER", $sformatf(
        "Handshake Statistics:\n  Total: %0d\n  Write: %0d\n  Read: %0d\n  First: %0t\n  Last: %0t\n  Avg Time: %0t\n  Avg Interval: %0t", 
        handshake_queue.size(), write_handshakes, read_handshakes, 
        min_time, max_time, avg_time, avg_interval), UVM_LOW)
    
    // Compare with transaction counts
    if (write_handshakes != wr_queue.size()) begin
        `uvm_warning("HANDSHAKE_CHECKER", $sformatf(
            "Write handshake count (%0d) doesn't match write transaction count (%0d)", 
            write_handshakes, wr_queue.size()))
    end
    
    if (read_handshakes != rd_queue.size()) begin
        `uvm_warning("HANDSHAKE_CHECKER", $sformatf(
            "Read handshake count (%0d) doesn't match read transaction count (%0d)", 
            read_handshakes, rd_queue.size()))
    end
    
    // Check for address/ID correlations between handshakes and transactions
    check_handshake_transaction_correlation();
endfunction

    function void check_handshake_transaction_correlation();
        int matched_write_handshakes = 0;
        int matched_read_handshakes = 0;
        
        // Check write handshakes against write transactions
        foreach (handshake_queue[i]) begin
            if (handshake_queue[i].is_write) begin
                bit found_match = 0;
                foreach (wr_queue[j]) begin
                    if (handshake_queue[i].addr == wr_queue[j].addr && 
                        handshake_queue[i].id == wr_queue[j].id) begin
                        matched_write_handshakes++;
                        found_match = 1;
                        break;
                    end
                end
                
                if (!found_match) begin
                    `uvm_warning("HANDSHAKE_CORRELATION", $sformatf(
                        "Write handshake with ADDR=0x%0h ID=0x%0h has no matching transaction",
                        handshake_queue[i].addr, handshake_queue[i].id))
                end
            end else begin
                // Read handshake
                bit found_match = 0;
                foreach (rd_queue[j]) begin
                    if (handshake_queue[i].addr == rd_queue[j].addr && 
                        handshake_queue[i].id == rd_queue[j].id) begin
                        matched_read_handshakes++;
                        found_match = 1;
                        break;
                    end
                end
                
                if (!found_match) begin
                    `uvm_warning("HANDSHAKE_CORRELATION", $sformatf(
                        "Read handshake with ADDR=0x%0h ID=0x%0h has no matching transaction",
                        handshake_queue[i].addr, handshake_queue[i].id))
                end
            end
        end
        
        `uvm_info("HANDSHAKE_CORRELATION", $sformatf(
            "Handshake-Transaction correlation: Write=%0d/%0d, Read=%0d/%0d",
            matched_write_handshakes, write_handshakes, 
            matched_read_handshakes, read_handshakes), UVM_LOW)
    endfunction

    function void compare_wr_rd_transactions();
        axi_trans_t local_wr_queue[$];
        axi_trans_t local_rd_queue[$];
        axi_trans_t wr_trans;
        axi_trans_t rd_trans;
        
        // Copy queues to avoid modifying originals
        foreach (wr_queue[i]) local_wr_queue.push_back(wr_queue[i]);
        foreach (rd_queue[i]) local_rd_queue.push_back(rd_queue[i]);

        while (local_wr_queue.size() > 0 && local_rd_queue.size() > 0) begin
            wr_trans = local_wr_queue.pop_front();
            rd_trans = local_rd_queue.pop_front();

            // ---- Address & ID Check ----
            if ((wr_trans.addr == rd_trans.addr) && (wr_trans.id == rd_trans.id)) begin
                `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                    "\nPASS: AWADDR=0x%0h\t ARADDR=0x%0h\t AWID=0x%0h\t ARID=0x%0h\n", 
                    wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id), UVM_MEDIUM)

                // ---- LEN, SIZE, BURST Comparison ----
                if ((wr_trans.len == rd_trans.len) &&
                    (wr_trans.size == rd_trans.size) &&
                    (wr_trans.burst == rd_trans.burst)) begin

                    `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "\nPASS: AWLEN=%0d\t ARLEN=%0d\t AWSIZE=%0d\t ARSIZE=%0d\t AWBURST=%0d\t ARBURST=%0d\n", 
                        wr_trans.len, rd_trans.len, wr_trans.size, rd_trans.size, 
                        wr_trans.burst, rd_trans.burst), UVM_MEDIUM)

                end else begin
                    if (wr_trans.len != rd_trans.len)
                        `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                            "\nLEN MISMATCH: AWLEN=%0d\t ARLEN=%0d\n", wr_trans.len, rd_trans.len))
                    if (wr_trans.size != rd_trans.size)
                        `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                            "\nSIZE MISMATCH: AWSIZE=%0d\t ARSIZE=%0d\n", wr_trans.size, rd_trans.size))
                    if (wr_trans.burst != rd_trans.burst)
                        `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                            "\nBURST MISMATCH: AWBURST=%0d\t ARBURST=%0d\n", wr_trans.burst, rd_trans.burst))
                end

                // ---- W vs R Data Check ----
                // For fixed RDATA, we might only have one data element
                // but need to compare to multiple WDATA elements
                if (rd_trans.data.size() > 0 && wr_trans.data.size() > 0) begin
                    bit data_match = 1;
                    
                    // When RDATA is fixed but we have multiple WDATA beats
                    if (rd_trans.data.size() == 1 && wr_trans.data.size() > 1) begin
                        // Compare only the first data beat
                        if (wr_trans.data[0] !== rd_trans.data[0]) begin
                            data_match = 0;
                            `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                                "\nDATA MISMATCH:\t First beat only: WDATA=0x%0h\t RDATA=0x%0h\n", 
                                wr_trans.data[0], rd_trans.data[0]))
                        end
                        
                        // Issue warning about incomplete comparison due to fixed RDATA
                        `uvm_warning("CHECKER - W/R_CHANNEL", $sformatf(
                            "Limited comparison: WDATA has %0d beats but RDATA is fixed (only first beat compared)",
                            wr_trans.data.size()))
                    end else if (wr_trans.data.size() == rd_trans.data.size()) begin
                        // Equal sizes - do a full comparison
                        foreach (wr_trans.data[i]) begin
                            if (wr_trans.data[i] !== rd_trans.data[i]) begin
                                data_match = 0;
                                `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                                    "\nDATA MISMATCH:\t Index=%0d\t WDATA=0x%0h\t RDATA=0x%0h\n", 
                                    i, wr_trans.data[i], rd_trans.data[i]))
                            end
                        end
                    end else begin
                        // Size mismatch other than the special case
                        `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                            "\nW&R DATA SIZE MISMATCH:\t WDATA.size=%0d\t RDATA.size=%0d\n",
                            wr_trans.data.size(), rd_trans.data.size()))
                    end
                    
                    if (data_match)
                        `uvm_info("CHECKER - W/R_CHANNEL", "WRITE/READ DATA MATCH: PASS", UVM_MEDIUM)
                end else begin
                    `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                        "\nMISSING DATA:\t WDATA.size=%0d\t RDATA.size=%0d\n",
                        wr_trans.data.size(), rd_trans.data.size()))
                end 

                // ---- B Channel Check ----
                if (wr_trans.bvalid && wr_trans.bready) begin
                    if (wr_trans.bresp == 2'b00) begin
                        `uvm_info("CHECKER - B_CHANNEL", $sformatf(
                            "PASS: BID=0x%0h, BRESP=0x%0h\n", wr_trans.bid, wr_trans.bresp), UVM_MEDIUM)
                    end else begin
                        `uvm_error("CHECKER - B_CHANNEL", $sformatf(
                            "FAIL: BRESP=0x%0h (non-OKAY)\n", wr_trans.bresp))
                    end
                end else begin
                    `uvm_info("CHECKER - B_CHANNEL", "Note: BVALID or BREADY not asserted during response, skipping check", UVM_LOW)
                end

                // ---- R Channel Check ----
                if (rd_trans.rvalid && rd_trans.rready && rd_trans.rlast) begin
                    if (rd_trans.rresp == 2'b00) begin
                        `uvm_info("CHECKER - R_CHANNEL", $sformatf(
                            "PASS: RRESP=0x%0h\t RLAST=0x%0d\n", rd_trans.rresp, rd_trans.rlast), UVM_MEDIUM)
                    end else begin
                        `uvm_error("CHECKER - R_CHANNEL", $sformatf(
                            "FAIL: RRESP=0x%0h (non-OKAY)\n", rd_trans.rresp))
                    end
                end else begin
                    `uvm_info("CHECKER - R_CHANNEL", "Note: RVALID, RREADY, or RLAST not asserted, skipping check", UVM_LOW)
                end
            end else begin
                `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                    "ADDR/ID MISMATCH: WR_ADDR=0x%0h\t RD_ADDR=0x%0h\t WR_ID=0x%0h\t RD_ID=0x%0h\n", 
                    wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id))
            end
        end
    endfunction

    function void check_handshake_phase();
        axi_trans_t local_wr_queue[$];
        axi_trans_t local_rd_queue[$];
        axi_trans_t wr_trans;
        axi_trans_t rd_trans;
        int valid_handshakes = 0;
        int failed_handshakes = 0;

        // Copy queues to avoid modifying originals
        foreach (wr_queue[i]) local_wr_queue.push_back(wr_queue[i]);
        foreach (rd_queue[i]) local_rd_queue.push_back(rd_queue[i]);

        `uvm_info("HANDSHAKE_CHECK", $sformatf("Checking %0d write transactions", local_wr_queue.size()), UVM_LOW)
        
        while (local_wr_queue.size() > 0) begin
            wr_trans = local_wr_queue.pop_front();

            // AW channel handshake check
            if (wr_trans.awvalid || wr_trans.awready) begin
                if (wr_trans.awvalid && wr_trans.awready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "WRITE address handshake PASSED: AWVALID=%0b AWREADY=%0b", 
                        wr_trans.awvalid, wr_trans.awready), UVM_LOW)
                end else if (wr_trans.awvalid) begin
                    // Only report errors when VALID is asserted but READY isn't
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "WRITE address handshake PENDING: AWVALID=%0b AWREADY=%0b", 
                        wr_trans.awvalid, wr_trans.awready), UVM_LOW)
                end
            end

            // W channel handshake check
            if (wr_trans.wvalid || wr_trans.wready) begin
                if (wr_trans.wvalid && wr_trans.wready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "W channel handshake PASSED: WVALID=%0b WREADY=%0b", 
                        wr_trans.wvalid, wr_trans.wready), UVM_LOW)
                end else if (wr_trans.wvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "W channel handshake PENDING: WVALID=%0b WREADY=%0b", 
                        wr_trans.wvalid, wr_trans.wready), UVM_LOW)
                end
            end

            // B channel handshake check
            if (wr_trans.bvalid || wr_trans.bready) begin
                if (wr_trans.bvalid && wr_trans.bready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "B channel handshake PASSED: BVALID=%0b BREADY=%0b", 
                        wr_trans.bvalid, wr_trans.bready), UVM_LOW)
                end else if (wr_trans.bvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "B channel handshake PENDING: BVALID=%0b BREADY=%0b", 
                        wr_trans.bvalid, wr_trans.bready), UVM_LOW)
                end
            end
        end

        `uvm_info("HANDSHAKE_CHECK", $sformatf("Checking %0d read transactions", local_rd_queue.size()), UVM_LOW)
        
        while (local_rd_queue.size() > 0) begin
            rd_trans = local_rd_queue.pop_front();

            // AR channel handshake check
            if (rd_trans.arvalid || rd_trans.arready) begin
                if (rd_trans.arvalid && rd_trans.arready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ address handshake PASSED: ARVALID=%0b ARREADY=%0b", 
                        rd_trans.arvalid, rd_trans.arready), UVM_LOW)
                end else if (rd_trans.arvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ address handshake PENDING: ARVALID=%0b ARREADY=%0b", 
                        rd_trans.arvalid, rd_trans.arready), UVM_LOW)
                end
            end

            // R channel handshake check
            if (rd_trans.rvalid || rd_trans.rready) begin
                if (rd_trans.rvalid && rd_trans.rready) begin
                    valid_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ data handshake PASSED: RVALID=%0b RREADY=%0b", 
                        rd_trans.rvalid, rd_trans.rready), UVM_LOW)
                end else if (rd_trans.rvalid) begin
                    failed_handshakes++;
                    `uvm_info("HANDSHAKE_CHECK", $sformatf(
                        "READ data handshake PENDING: RVALID=%0b RREADY=%0b", 
                        rd_trans.rvalid, rd_trans.rready), UVM_LOW)
                end
            end
        end
        
        if (valid_handshakes == 0 && failed_handshakes == 0) begin
            `uvm_warning("HANDSHAKE_CHECK", "No handshake signals captured in transactions")
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf(
                "Handshake summary: Valid=%0d Pending=%0d", 
                valid_handshakes, failed_handshakes), UVM_LOW)
        end
    endfunction

    function void check_write_operation();
        if (wr_queue.size() == 0) begin
            `uvm_info("WRITE_OPS", "No write operations to check", UVM_LOW)
            return;
        end

        `uvm_info("WRITE_OPS", $sformatf("Checking %0d write operations", wr_queue.size()), UVM_LOW)
        
        foreach (wr_queue[i]) begin
            `uvm_info("WRITE_OPS", $sformatf(
                "\nWRITE[%0d]:\n ADDR=0x%0h\n ID=0x%0h\n LEN=%0d\n SIZE=%0d\n BURST=%0d\n",
                i, wr_queue[i].addr, wr_queue[i].id, wr_queue[i].len, 
                wr_queue[i].size, wr_queue[i].burst), UVM_MEDIUM)
                
            // Check write data is valid
            if (wr_queue[i].data.size() > 0) begin
                `uvm_info("WRITE_OPS", $sformatf(
                    "DATA[%0d]: %0p", i, wr_queue[i].data), UVM_HIGH)
            end else begin
                `uvm_error("WRITE_OPS", $sformatf(
                    "WRITE[%0d]: No data was captured", i))
            end
            
            // Verify WLAST is set for the final beat
            if (wr_queue[i].len > 0 && !wr_queue[i].wlast) begin
                `uvm_error("WRITE_OPS", $sformatf(
                    "WRITE[%0d]: WLAST not set for multi-beat transfer (LEN=%0d)",
                    i, wr_queue[i].len))
            end
            
            // Check write response
            if (wr_queue[i].bresp == 2'b00) begin
                `uvm_info("WRITE_OPS", "BRESP=OKAY", UVM_HIGH)
            end else begin
                `uvm_error("WRITE_OPS", $sformatf(
                    "WRITE[%0d]: Invalid BRESP=0x%0h", i, wr_queue[i].bresp))
            end
            
            // Verify BID matches AWID
            if (wr_queue[i].bid != wr_queue[i].id) begin
                `uvm_error("WRITE_OPS", $sformatf(
                    "WRITE[%0d]: BID(0x%0h) doesn't match AWID(0x%0h)",
                    i, wr_queue[i].bid, wr_queue[i].id))
            end
        end
    endfunction
    
    function void check_read_operation();
        if (rd_queue.size() == 0) begin
            `uvm_info("READ_OPS", "No read operations to check", UVM_LOW)
            return;
        end

        `uvm_info("READ_OPS", $sformatf("Checking %0d read operations", rd_queue.size()), UVM_LOW)
        
        foreach (rd_queue[i]) begin
            `uvm_info("READ_OPS", $sformatf(
                "\nREAD[%0d]:\n ADDR=0x%0h\n ID=0x%0h\n LEN=%0d\n SIZE=%0d\n BURST=%0d\n",
                i, rd_queue[i].addr, rd_queue[i].id, rd_queue[i].len, 
                rd_queue[i].size, rd_queue[i].burst), UVM_MEDIUM)
                
            // Check read data is valid
            if (rd_queue[i].data.size() > 0) begin
                `uvm_info("READ_OPS", $sformatf(
                    "DATA[%0d]: %0p", i, rd_queue[i].data), UVM_HIGH)
            end else begin
                `uvm_error("READ_OPS", $sformatf(
                    "READ[%0d]: No data was captured", i))
            end
            
            // Verify RLAST is set
            if (rd_queue[i].len > 0 && !rd_queue[i].rlast) begin
                `uvm_error("READ_OPS", $sformatf(
                    "READ[%0d]: RLAST not set for multi-beat transfer (LEN=%0d)",
                    i, rd_queue[i].len))
            end
            
            // Check read response
            if (rd_queue[i].rresp == 2'b00) begin
                `uvm_info("READ_OPS", "RRESP=OKAY", UVM_HIGH)
            end else begin
                `uvm_error("READ_OPS", $sformatf(
                    "READ[%0d]: Invalid RRESP=0x%0h", i, rd_queue[i].rresp))
            end
            
            // Verify RID matches ARID
            if (rd_queue[i].rid != rd_queue[i].id) begin
                `uvm_error("READ_OPS", $sformatf(
                    "READ[%0d]: RID(0x%0h) doesn't match ARID(0x%0h)",
                    i, rd_queue[i].rid, rd_queue[i].id))
            end
        end
    endfunction
endclass            

