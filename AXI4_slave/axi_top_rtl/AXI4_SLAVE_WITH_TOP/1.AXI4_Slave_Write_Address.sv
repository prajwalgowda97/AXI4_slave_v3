module axi4_slave_write_address
#(
//=========================PARAMETERS=============================
      parameter ADDR_WIDTH   = 32   ,
      parameter ID_WIDTH     = 4    ,
      parameter BURST_LENGTH = 8
) (
//=========================INPUT SIGNALS===========================
      input logic                            clk        ,   //Clock Signal
      input logic                            rst        ,   //Reset Signal
      input logic                            awvalid    ,   //Address valid from master
      input logic   [ADDR_WIDTH - 1 : 0]     awaddr     ,   //write address Signal
      input logic   [ID_WIDTH   - 1 : 0]     awid       ,   //write address: ID Signal
      input logic   [BURST_LENGTH - 1 : 0]   awlen      ,   //Burst length Signal
      input logic   [2:0]                    awsize     ,   //Burst size Signal
      input logic   [1:0]                    awburst    ,   //Burst type Signal

//=========================OUTPUT SIGNALS==========================
      output logic                            awready   ,   //Write Ready Signal
      output logic  [ID_WIDTH   - 1 : 0]   stored_awid
);
//=========================FSM STATES==============================
    typedef enum logic [1:0] {
                                AW_IDLE = 2'b00,
                                AW_ADDR = 2'b01
                             } FSM_STATE;
    FSM_STATE present_state,next_state;

//===========================INTERNAL REGISTERS=======================
    logic                           SLV_AWREADY         ;
    logic [ADDR_WIDTH-1:0]          SLV_BURST_ADDR      ; 
    logic [BURST_LENGTH-1:0]        SLV_BURST_COUNTER   ;

//==========================RESET LOGIC=================================
    always_ff @(posedge clk or negedge rst)
      begin
        if(!rst)
              present_state <= AW_IDLE;
            else
              present_state <= next_state;
      end

//========================STATE LOGIC===============================
    always @(*)
      begin
        next_state = present_state;
        case(present_state)
           AW_IDLE : begin
              if(awvalid)
                     next_state = AW_ADDR;
               else
                     next_state = AW_IDLE;
                  end

          AW_ADDR : begin
                   if(!awvalid)
                               next_state = AW_IDLE;
                   else
                                next_state = AW_ADDR;
                end
            
       endcase
    end
//======================OUTPUT LOGIC=================================
    always_ff @(posedge clk or negedge rst)
       begin
        if(!rst)
           begin
                SLV_AWREADY        <= 1'b0;
                SLV_BURST_ADDR     <= 32'h0;
                SLV_BURST_COUNTER  <= {BURST_LENGTH{1'b0}};
                stored_awid        <= {ID_WIDTH{1'b0}};
           end
        else

          begin
        case(present_state)
                AW_IDLE:
                begin
                    if (awvalid)
                    begin
                        SLV_AWREADY     <= 1'b1;
                        SLV_BURST_ADDR  <= awaddr;
                        SLV_BURST_COUNTER <= awlen;
                        stored_awid       <= awid;
                    end
                    else
                    begin
                        SLV_AWREADY <= 1'b0;
                    end
                end
                
                AW_ADDR:
                begin
                    SLV_AWREADY <= 1'b0;
                    if (SLV_BURST_COUNTER > 0)
                    begin
                        case (awburst)
                            2'b00:   SLV_BURST_ADDR <= SLV_BURST_ADDR; // Fixed burst
                            2'b01:   SLV_BURST_ADDR <= SLV_BURST_ADDR + (1 << awsize); // Incremental burst
                            2'b10:   SLV_BURST_ADDR <= SLV_BURST_ADDR + ((SLV_BURST_COUNTER & 1) ? -(1 << awsize) : (1 << awsize)); // Wrap burst
                            default: SLV_BURST_ADDR <= SLV_BURST_ADDR; // Reserved No Change
                        endcase
                        SLV_BURST_COUNTER <= SLV_BURST_COUNTER - 1;
                    end
                end
            endcase
        end
    end
assign awready = SLV_AWREADY;

endmodule 
