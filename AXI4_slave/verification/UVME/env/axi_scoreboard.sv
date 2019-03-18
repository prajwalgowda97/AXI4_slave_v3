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
                $sformatf("WRITE Address: AWADDR=0x%0h, AWID=0x%0h, AWLEN=%0h, AWSIZE=%0d, AWBURST=%0d", 
                t.AWADDR, t.AWID, t.AWLEN, t.AWSIZE, t.AWBURST), UVM_MEDIUM)

            `uvm_info("SCOREBOARD", 
                $sformatf("WRITE Data: WDATA=0x%0p, WSTRB=0x%0h, WLAST=%0d", 
                t.WDATA, t.WSTRB, t.WLAST), UVM_MEDIUM)
            
            `uvm_info("SCOREBOARD", 
                $sformatf("WRITE Response: BID=0x%0h, BRESP=0x%0d", 
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
                $sformatf("READ Address: ARADDR=0x%0h, ARID=0x%0h, ARLEN=%0d, ARSIZE=%0d, ARBURST=%0d", 
                t.ARADDR, t.ARID, t.ARLEN, t.ARSIZE, t.ARBURST), UVM_MEDIUM)

            `uvm_info("SCOREBOARD", 
                $sformatf("READ Data: RDATA=0x%0h, RRESP=0x%0h, RLAST=0x%0h", 
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
                "PASS: AWADDR=0x%0h, AWID=0x%0h, ARADDR=0x%0h, ARID=0x%0h", wr_trans.addr, wr_trans.id, rd_trans.addr, rd_trans.id), UVM_MEDIUM)

            // ---- LEN, SIZE, BURST Comparison ----
            if ((wr_trans.len == rd_trans.len) &&
                (wr_trans.size == rd_trans.size) &&
                (wr_trans.burst == rd_trans.burst)) begin

                `uvm_info("CHECKER - AW/AR_CHANNEL", $sformatf(
                    "PASS: AWLEN=%0d, AWSIZE=%0d, AWBURST=%0d, ARLEN=%0d, ARSIZE=%0d, ARBURST=%0d", wr_trans.len, wr_trans.size, wr_trans.burst, rd_trans.len, rd_trans.size, rd_trans.burst), UVM_MEDIUM)

            end else begin
                if (wr_trans.len != rd_trans.len)
                    `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "LEN MISMATCH: AWLEN=%0d, ARLEN=%0d", wr_trans.len, rd_trans.len))
                if (wr_trans.size != rd_trans.size)
                    `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "SIZE MISMATCH: AWSIZE=%0d, ARSIZE=%0d", wr_trans.size, rd_trans.size))
                if (wr_trans.burst != rd_trans.burst)
                    `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                        "BURST MISMATCH: AWBURST=%0d, ARBURST=%0d", wr_trans.burst, rd_trans.burst))
            end

            // ---- W vs R Data Check ----
            if (wr_trans.data.size() == rd_trans.data.size()) begin
                bit all_match = 1;
                foreach (wr_trans.data[i]) begin
                    if (wr_trans.data[i] !== rd_trans.data[i]) begin
                        all_match = 0;
                        `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                            "DATA MISMATCH: AWID=%0d, WDATA=0x%0h, ARID=%0d, RDATA=0x%0h", 
                            wr_trans.id[i], rd_trans.id[i], wr_trans.data[i], rd_trans.data[i]))
                    end
                end
                
                if (all_match)
                    `uvm_info("CHECKER - W/R_CHANNEL", "WRITE/READ DATA MATCH: PASS", UVM_MEDIUM)
            end else begin
                `uvm_error("CHECKER - W/R_CHANNEL", $sformatf(
                    "W&R DATA MISMATCH: AWADDR=0x%0h, ARADDR=0x%0h, AWID=0x%0h, ARID=0x%0h, AWLEN=%0d, ARLEN=%0d, AWSIZE=%0d, ARSIZE=%0d, AWBURST=%0d, ARBURST=%0d, WDATA.size=%0d, RDATA.size=%0d, WDATA=0x%p, RDATA=0x%p", wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id, wr_trans.len, rd_trans.len, wr_trans.size, rd_trans.size, wr_trans.burst, rd_trans.burst, wr_trans.data.size(), rd_trans.data.size(), rd_trans.id, rd_trans.data
                    ))
            end 

            // ---- B Channel Check ----
            if (wr_trans.bvalid && wr_trans.bready) begin
                if (wr_trans.resp == 2'b00) begin
                    `uvm_info("CHECKER - B_CHANNEL", $sformatf(
                        "PASS: BID=0x%0h, BRESP=0x%0h", wr_trans.bid, wr_trans.resp), UVM_MEDIUM)
                end else begin
                    `uvm_error("CHECKER - B_CHANNEL", $sformatf(
                        "FAIL: BRESP=0x%0h (non-OKAY)", wr_trans.resp))
                end
            end else begin
                `uvm_error("CHECKER - B_CHANNEL", "BVALID or BREADY not asserted during response")
            end

            // ---- R Channel Check ----
            if (rd_trans.valid && rd_trans.ready && rd_trans.last) begin
                if (rd_trans.resp == 2'b00) begin
                    `uvm_info("CHECKER - R_CHANNEL", $sformatf(
                        "PASS: RRESP=0x%0h, RLAST=0x%0d", rd_trans.resp, rd_trans.last), UVM_MEDIUM)
                end else begin
                    `uvm_error("CHECKER - R_CHANNEL", $sformatf(
                        "FAIL: RRESP=0x%0h (non-OKAY)", rd_trans.resp))
                end
            end else begin
                `uvm_error("CHECKER - R_CHANNEL", "RVALID, RREADY, or RLAST not asserted")
            end

        end else begin
            `uvm_error("CHECKER - AW/AR_CHANNEL", $sformatf(
                "ADDR/ID MISMATCH: WR_ADDR=0x%0h, RD_ADDR=0x%0h, WR_ID=0x%0h, RD_ID=0x%0h", 
                wr_trans.addr, rd_trans.addr, wr_trans.id, rd_trans.id))
        end
    end
endfunction 


endclass 


