class axi_seq_item extends uvm_sequence_item;
int i;
//Make the output signals as logic
      rand  logic                wr_rd     ;
      rand  logic                handshake ;
      rand  logic                CLK       ;    //Clock Signal
      rand  logic                RST       ;    //Reset Signal
      rand  logic                AWVALID   ;    //master indicating address is valid
      rand  logic   [31 : 0]     AWADDR    ;    //write address
      rand  logic   [3  : 0]     AWID      ;    //write address: ID
      rand  logic   [7  : 0]     AWLEN     ;    //burst length
      rand  logic   [2:0]        AWSIZE    ;    //burst size
      rand  logic   [1:0]        AWBURST   ;    //burst type
            logic                AWREADY   ;    //slave ready to accept write address
            logic                WREADY    ;    //write ready
      rand  logic                WVALID    ;    //write valid
      rand  logic   [31 : 0]     WDATA[$]  ;    //write data
      rand  logic                WLAST     ;    //write last beat
      rand  logic   [3  : 0]     WSTRB     ;    //write strobe
//    rand  logic   [3  : 0]     WID       ;    //Write Data ID is not required for AXI4
            logic                BVALID    ;    //slave indicates response is valid
            logic   [3  : 0]     BID       ;    //response id
            logic   [1  : 0]     BRESP     ;    //write response
      rand  logic                BREADY    ;    //master ready to accept the response
            logic                ARREADY   ;    //slave ready to accept write address
      rand  logic                ARVALID   ;    //master indicating address is valid
      rand  logic   [31 : 0]     ARADDR    ;    //read address
      rand  logic   [3  : 0]     ARID      ;    //transaction ID
      rand  logic   [7  : 0]     ARLEN     ;    //burst length
      rand  logic   [2  : 0]     ARSIZE    ;    //burst size
      rand  logic   [1  : 0]     ARBURST   ; 
            logic                RVALID    ;    //slave indicates data is valid
            logic   [31 : 0]     RDATA     ;    //read data
            logic   [3  : 0]     RID       ;    //read ID
            logic                RLAST     ;    //indicates last transfer in a burst
            logic   [1:0]        RRESP     ;    //
      rand  logic                RREADY    ;    //master is ready to accept data


  `uvm_object_utils_begin(axi_seq_item) 
  `uvm_field_int(CLK        ,UVM_ALL_ON)
  `uvm_field_int(RST        ,UVM_ALL_ON)
  `uvm_field_int(AWVALID    ,UVM_ALL_ON)
  `uvm_field_int(AWADDR     ,UVM_ALL_ON)
  `uvm_field_int(AWID       ,UVM_ALL_ON)
  `uvm_field_int(AWLEN      ,UVM_ALL_ON)
  `uvm_field_int(AWSIZE     ,UVM_ALL_ON)
  `uvm_field_int(AWBURST    ,UVM_ALL_ON)
  `uvm_field_int(AWREADY    ,UVM_ALL_ON)
  `uvm_field_int(WREADY     ,UVM_ALL_ON)
  `uvm_field_int(WVALID     ,UVM_ALL_ON)
  `uvm_field_queue_int(WDATA      ,UVM_ALL_ON)
  `uvm_field_int(WLAST      ,UVM_ALL_ON)
  `uvm_field_int(WSTRB      ,UVM_ALL_ON)
//`uvm_field_int(WID        ,UVM_ALL_ON)
  `uvm_field_int(BVALID     ,UVM_ALL_ON)
  `uvm_field_int(BID        ,UVM_ALL_ON)
  `uvm_field_int(BRESP      ,UVM_ALL_ON)
  `uvm_field_int(BREADY     ,UVM_ALL_ON)
  `uvm_field_int(ARREADY    ,UVM_ALL_ON)
  `uvm_field_int(ARVALID    ,UVM_ALL_ON)
  `uvm_field_int(ARADDR     ,UVM_ALL_ON)
  `uvm_field_int(ARID       ,UVM_ALL_ON)
  `uvm_field_int(ARLEN      ,UVM_ALL_ON)
  `uvm_field_int(ARSIZE     ,UVM_ALL_ON)
  `uvm_field_int(ARBURST    ,UVM_ALL_ON)
  `uvm_field_int(RVALID     ,UVM_ALL_ON)
  `uvm_field_int(RDATA      ,UVM_ALL_ON)
  `uvm_field_int(RID        ,UVM_ALL_ON)
  `uvm_field_int(RLAST      ,UVM_ALL_ON)
  `uvm_field_int(RRESP      ,UVM_ALL_ON)
  `uvm_field_int(RREADY     ,UVM_ALL_ON) 
  `uvm_object_utils_end

 //constructor
  function new(string name="axi_seq_item");
   super.new(name);
  endfunction
constraint wdata_i {WDATA.size()==AWLEN+1;}
endclass
