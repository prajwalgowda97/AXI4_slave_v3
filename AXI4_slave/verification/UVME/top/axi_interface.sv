interface axi_interface (input bit CLK);

      logic RST       ;    //Reset Signal
      logic                AWVALID   ;    //master indicating address is valid
      logic   [31 : 0]     AWADDR    ;    //write address
      logic   [3  : 0]     AWID      ;    //write address: ID
      logic   [7  : 0]     AWLEN     ;    //burst length
      logic   [2:0]        AWSIZE    ;    //burst size
      logic   [1:0]        AWBURST   ;    //burst type
      logic                AWREADY   ;    //slave ready to accept write address
      logic                WREADY    ;    //write ready
      logic                WVALID    ;    //write valid
      logic   [31 : 0]     WDATA     ;    //write data
      logic                WLAST     ;    //write last beat
      logic   [3  : 0]     WSTRB     ;    //write strobe
//    logic   [3  : 0]     WID       ;    //Write Data ID is not required for AXI4
      logic                BVALID    ;    //slave indicates response is valid
      logic   [3  : 0]     BID       ;    //response id
      logic   [1  : 0]     BRESP     ;    //write response
      logic                BREADY    ;    //master ready to accept the response
      logic                ARREADY   ;    //slave ready to accept write address
      logic                ARVALID   ;    //master indicating address is valid
      logic   [31 : 0]     ARADDR    ;    //read address
      logic   [3  : 0]     ARID      ;    //transaction ID
      logic   [7  : 0]     ARLEN     ;    //burst length
      logic   [2  : 0]     ARSIZE    ;    //burst size
      logic   [1  : 0]     ARBURST   ; 
      logic                RVALID    ;    //slave indicates data is valid
      logic   [31 : 0]     RDATA     ;    //read data
      logic   [3  : 0]     RID       ;    //read ID
      logic                RLAST     ;    //indicates last transfer in a burst
      logic   [1:0]        RRESP     ;    //
      logic                RREADY    ;     //master is ready to accept data

  clocking driver_cb@(posedge CLK);
   default  input #0 output #0;
        output RST;
        output AWADDR, AWLEN, AWBURST, AWSIZE, AWID, AWVALID;
        input  AWREADY;
        output WDATA, WLAST, WSTRB, WVALID;
        input  WREADY;
        output BREADY;
        input  BID, BVALID, BRESP;
        output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID;
        input  ARREADY;
        output RREADY;
        input  RDATA, RID, RLAST, RRESP, RVALID;
        
   endclocking

/*modport DUT (input CLK, RST, AWVALID, AWADDR, AWID, AWLEN, AWSIZE, AWBURST, WVALID, WDATA, WSTRB, WLAST, BREADY, 
               output AWREADY, WREADY, BVALID, BRESP, BID);

  modport TB (clocking clk_cb, input RST);*/

endinterface
