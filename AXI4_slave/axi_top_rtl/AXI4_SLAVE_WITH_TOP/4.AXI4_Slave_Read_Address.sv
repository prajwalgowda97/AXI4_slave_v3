module axi4_slave_read_address
#(
//=========================PARAMETERS=============================
      parameter ADDR_WIDTH   = 32,
      parameter ID_WIDTH     = 4,
      parameter BURST_LENGTH = 8
) (
//=========================INPUT SIGNALS===========================
      input  logic                            clk,
      input  logic                            rst,
      input  logic                            arvalid,    //master indicating address is valid
      input  logic   [ADDR_WIDTH - 1 : 0]     araddr,     //write address
      input  logic   [ID_WIDTH   - 1 : 0]     arid,       //write address: ID
      input  logic   [BURST_LENGTH - 1 : 0]   arlen,       //burst length
      input  logic   [2:0]                    arsize,     ///burst size
      input  logic   [1:0]                    arburst,     ////burst type
        
//=========================OUTPUT SIGNALS==========================
      output logic                            arready
);
//=========================FSM STATES==============================
    typedef enum logic [1:0] {
                                IDLE       = 2'b00,
                                ADDR_STATE = 2'b01
                             } FMS_STATE;
    FMS_STATE present_state,next_state;

//===========================INTERNAL REGISTERS======================
    logic                       arready_reg;
    logic [ADDR_WIDTH-1:0]      burst_addr; ////internal address counter for bursts
    logic [BURST_LENGTH-1:0]    burst_counter;
 
//==========================RESET LOGIC==============================
    always_ff @(posedge clk or negedge rst)
      begin
        if(!rst)
            begin
              present_state <= IDLE;
            end
            else
            begin
              present_state <= next_state;
            end
      end

//========================STATE LOGIC===============================
    always @(*)
      begin
         next_state = present_state;
        case(present_state)
           IDLE : begin
              if(arvalid)
                  begin
                     next_state = ADDR_STATE;
                  end
               else
                  begin
                     next_state = IDLE;
                  end
                  end

          ADDR_STATE : begin
               if(arready)
                   begin
                              next_state = ADDR_STATE;
                       end
                   else
                      begin
                                next_state = IDLE;
                      end
              end
      endcase
    end
//======================OUTPUT LOGIC=================================
    always_ff @(posedge clk or negedge rst)
       begin
        if(!rst)
           begin
                arready_reg        <= 1'b0;
               burst_addr         <= 32'h0;

           end
        else

          begin
        case(present_state)

          IDLE : begin
                            //  awvalid_reg       <= 1'b0;
                           // burst_counter <= awlen_reg; ///load burst length

                           if(arvalid)
                               begin
                                  arready_reg <= 1'b1;
                               end
                            else
                                begin
                                   arready_reg <= 1'b0;
                                end
               
                 end

          ADDR_STATE : begin
                               arready_reg <= 1'b0;
                               if(burst_counter != arlen)
                                   begin
                     case(arburst)
 2'b00:   burst_addr <= burst_addr; // Fixed burst
 2'b01:   burst_addr <= burst_addr + (1 << arsize); // Incremental burst
 2'b10:   burst_addr <= burst_addr + ((burst_counter & 1) ? -(1 << arsize) : (1 << arsize)); // Wrap burst
 default: burst_addr <= burst_addr; // Reserved No Need
                     endcase
               end
            end
       endcase
    end 
end

always_ff @(posedge clk or negedge rst)
 begin
 if(!rst)
     begin
     burst_counter<=BURST_LENGTH;
     end
     else 
         begin
    /////// decrement burst counter/////////////

     if(burst_counter > 0 && burst_addr == 2'b01) //&& present_state==ADDR_STATE)
         begin
             burst_counter <= burst_counter - 1;
         end
        else
            burst_counter <= 0;
         end
  end


 //   assign awid = awid_reg;
  //  assign awlen = awlen_reg;
   // assign awsize = awsize_reg;
   // assign awburst = awburst_reg;
  //  assign awaddr = awaddr_reg;
    assign arready = arready_reg;
 //   assign awready = awready_reg;
 //   assign awready = awready_reg;
   endmodule 
