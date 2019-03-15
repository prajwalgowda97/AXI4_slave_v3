module axi4_slave_top 
#(
//=========================PARAMETERS=============================
    parameter ADDR_WIDTH     = 32   ,
    parameter DATA_WIDTH     = 32   ,
    parameter ID_WIDTH       = 4    ,
    parameter BURST_LENGTH   = 8    ,
    parameter LEN_WIDTH      = 8    ,
    parameter SIZE_WIDTH     = 3
   )(
//========================Global Signals==========================
     input   logic                            CLK       ,    //Clock Signal
     input   logic                            RST       ,    //Reset Signal


//====================Write Address Channel Signals===============
     input   logic                            AWVALID   ,    //master indicating address is valid
     input   logic   [ADDR_WIDTH - 1 : 0]     AWADDR    ,    //write address
     input   logic   [ID_WIDTH   - 1 : 0]     AWID      ,    //write address: ID
     input   logic   [BURST_LENGTH - 1 : 0]   AWLEN     ,    //burst length
     input   logic   [2:0]                    AWSIZE    ,    //burst size
     input   logic   [1:0]                    AWBURST   ,    //burst type
     output  logic                            AWREADY   ,    //slave ready to accept write address

//====================Write Data Channel Signals==================
     output  logic                            WREADY    ,    //write ready
     input   logic   [BURST_LENGTH - 1 : 0]   burst_length,  //burst length (number of beats)
     input   logic                            WVALID    ,    //write valid
     input   logic   [DATA_WIDTH - 1 : 0]     WDATA     ,    //write data
     input   logic                            WLAST     ,    //write last beat
     input   logic   [ID_WIDTH - 1 : 0]       WSTRB     ,    //write strobe
//     input   logic   [ID_WIDTH - 1 : 0]       WID       ,    //Write Data ID is not required for AXI4

//====================Write Response Channel Signals===============
     output  logic                            BVALID    ,    //slave indicates response is valid
     output  logic   [ID_WIDTH - 1 : 0 ]      BID       ,    //response id
     output  logic   [1:0]                    BRESP     ,    //write response
     input   logic                            BREADY    ,    //master ready to accept the response
//=====================Read Address Channel Signals===============
     output  logic                            ARREADY   ,    //slave ready to accept write address
     input   logic                            ARVALID   ,    //master indicating address is valid
     input   logic   [ADDR_WIDTH - 1 : 0]     ARADDR    ,    //read address
     input   logic   [ID_WIDTH   - 1 : 0]     ARID      ,    //transaction ID
     input   logic   [LEN_WIDTH - 1 : 0]      ARLEN     ,    //burst length
     input   logic   [SIZE_WIDTH - 1 : 0]     ARSIZE    ,    //burst size
     input   logic   [1 : 0]                  ARBURST   , 

//=====================Read Data Channel Signals===============
     output  logic                            RVALID    ,    //slave indicates data is valid
     output  logic   [DATA_WIDTH - 1 : 0]     RDATA     ,    //read data
     output  logic   [ID_WIDTH  - 1 : 0]      RID       ,    //read ID
     output  logic                            RLAST     ,    //indicates last transfer in a burst
     output  logic   [1:0]                    RRESP     ,    //
     input   logic                            RREADY         //master is ready to accept data
 );

//----------------------------------//
//          Internal Signals        //
//----------------------------------//

 logic   [ID_WIDTH-1:0]           stored_awid;
 logic   [ID_WIDTH-1:0]         stored_awid_in;


//=========================Write Address Channel Initialization=================================
axi4_slave_write_address 
#(
                         .ADDR_WIDTH     (ADDR_WIDTH)   ,
                         .ID_WIDTH       (ID_WIDTH)     ,
                         .BURST_LENGTH   (BURST_LENGTH)
      ) write_addr (
                         .clk            (CLK)          ,
                         .rst            (RST)          ,
                         .awready        (AWREADY)      ,
                         .awvalid        (AWVALID)      ,
                         .awaddr         (AWADDR)       ,
                         .awid           (AWID)         ,
                         .awlen          (AWLEN)        ,
                         .awsize         (AWSIZE)       ,
                         .awburst        (AWBURST)      ,
                         .stored_awid    (stored_awid)  
);

 //=========================Write Data Channel Initialization=================================
axi4_slave_data_channel 
#(
                        .DATA_WIDTH     (DATA_WIDTH)    ,
                        .ID_WIDTH       (ID_WIDTH)      ,
                        .BURST_LENGTH   (BURST_LENGTH)
      ) write_data_dut (
                        .clk            (CLK)           ,
                        .rst            (RST)           ,
                        .awvalid        (AWVALID)       ,
                        .awready        (AWREADY)       ,
                        .wready         (WREADY)        ,
                        .burst_length   (AWLEN)         ,
                        .wvalid         (WVALID)        ,
                        .wdata          (WDATA)         ,
                        .wlast          (WLAST)         ,
                        .wstrb          (WSTRB)         ,
//                      .wid            (WID)           ,// NOT REQUIRED FOR AXI4
                        .count_done     ()
);

//=========================Write Response Channel Initialization=================================
axi4_slave_write_response 
#(
                        .ID_WIDTH(ID_WIDTH)
      ) write_response (
                        .clk            (CLK)           ,
                        .rst            (RST)           ,
                        .bvalid         (BVALID)        ,
                        .bid            (BID)           ,
                        .bresp          (BRESP)         ,
                        .wlast          (WLAST)         ,
                        .bready         (BREADY)        ,
                        .stored_awid_in (stored_awid)
);

//=========================Read Address Channel Initialization=================================
axi4_slave_read_address 
#(
                        .ADDR_WIDTH     (ADDR_WIDTH)    ,
                        .ID_WIDTH       (ID_WIDTH)
      ) read_address (
                        .clk            (CLK)           ,
                        .rst            (RST)           ,
                        .arready        (ARREADY)       ,
                        .arvalid        (ARVALID)       ,
                        .araddr         (ARADDR)        ,
                        .arid           (ARID)          ,
                        .arlen          (ARLEN)         ,
                        .arsize         (ARSIZE)        ,
                        .arburst        (ARBURST)
);

//=========================Read Data Channel Initialization=================================
axi4_slave_read_data 
#(
                        .DATA_WIDTH     (DATA_WIDTH)    ,
                        .ID_WIDTH       (ID_WIDTH)      ,
                        .BURST_LENGTH   (BURST_LENGTH)
      ) read_data (
                        .clk            (CLK)           ,
                        .rst            (RST)           ,
                        .arvalid        (ARVALID)       ,
                        .arready        (ARREADY)       ,
                        .rvalid         (RVALID)        ,
                        .rdata          (RDATA)         ,
                        .rid            (RID)           ,
                        .rlast          (RLAST)         ,
                        .rresp          (RRESP)         ,
                        .burst_length   (ARLEN)         ,
                        .rready         (RREADY)
);                                                                         

endmodule
