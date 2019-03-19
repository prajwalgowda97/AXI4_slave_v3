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

class axi_scoreboard extends uvm_scoreboard;
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

super.check_phase(phase);

    // Call all checkers
    check_handshake_phase();
    check_write_operation();
    check_read_operation();

   axi_trans_t wr, rd;

    while (wr_queue.size() > 0 && rd_queue.size() > 0) begin
        wr = wr_queue.pop_front();
        rd = rd_queue.pop_front();

        // WRITE Address handshake
        if (!(wr.valid && wr.ready)) begin
            `uvm_error("HANDSHAKE_CHECK", $sformatf("WRITE address handshake failed: AWVALID=%0b AWREADY=%0b", wr.valid, wr.ready))
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("WRITE address handshake PASSED: AWVALID=%0b AWREADY=%0b", wr.valid, wr.ready), UVM_LOW)
        end

        // WRITE response handshake
        if (!(wr.bvalid && wr.bready)) begin
            `uvm_error("HANDSHAKE_CHECK", $sformatf("B channel handshake failed: BVALID=%0b BREADY=%0b", wr.bvalid, wr.bready))
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("B channel handshake PASSED: BVALID=%0b BREADY=%0b", wr.bvalid, wr.bready), UVM_LOW)
        end

        // READ data handshake
        if (!(rd.valid && rd.ready)) begin
            `uvm_error("HANDSHAKE_CHECK", $sformatf("READ channel handshake failed: RVALID=%0b RREADY=%0b", rd.valid, rd.ready))
        end else begin
            `uvm_info("HANDSHAKE_CHECK", $sformatf("READ channel handshake PASSED: RVALID=%0b RREADY=%0b", rd.valid, rd.ready), UVM_LOW)
        end
    end
endfunction

function void check_write_operation();
    axi_trans_t wr;

    while (wr_queue.size() > 0) begin
        wr = wr_queue.pop_front();

        // Address phase handshake
        if (!(wr.valid && wr.ready))
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

function void check_read_operation();
    axi_trans_t rd;

    while (rd_queue.size() > 0) begin
        rd = rd_queue.pop_front();

        // Address phase handshake
        if (!(rd.valid && rd.ready))
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

endclass 




