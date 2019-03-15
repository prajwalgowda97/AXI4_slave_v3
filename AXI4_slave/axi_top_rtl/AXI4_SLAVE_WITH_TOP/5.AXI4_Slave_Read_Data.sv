module axi4_slave_read_data 
#(
//=========================PARAMETERS=============================
      parameter DATA_WIDTH = 32,
      parameter ID_WIDTH   = 4,
      parameter BURST_LENGTH = 8
) (
//=========================INPUT SIGNALS===========================
      input      logic                              clk,
      input      logic                              rst,
      input       logic                              arvalid,
      input       logic                              arready,
      output      logic                              rvalid,      ///slave indicates data is valid
      output      logic    [DATA_WIDTH - 1 : 0]      rdata,       //////read data
      output      logic    [ID_WIDTH  - 1 : 0]       rid,         /////read ID
      output      logic                              rlast,       /////indicates last transfer in a burst
      output      logic    [1:0]                     rresp,
      input       logic    [BURST_LENGTH - 1 : 0]    burst_length,
      input       logic    [DATA_WIDTH - 1 : 0]      data_in, 
//=========================OUTPUT SIGNALS==========================
      input     logic                              rready     ///master is ready to accept data
       
);
//=========================FSM STATES==============================
      typedef enum logic   [1:0] {
                                    IDLE       = 2'b00,
                                    READ_DATA  = 2'b01,
                                    WAIT_ACK   = 2'b10
                                  } FMS_STATE;
       FMS_STATE present_state,next_state;

       
 string response_string;
//===========================INTERNAL REGISTERS======================
      logic    [BURST_LENGTH - 1 : 0]   burst_count;
      logic    [BURST_LENGTH - 1 : 0]   counter;
      logic                             count_en;
      logic                             count_done;
//==========================RESET LOGIC==============================
       always @(posedge clk or negedge rst)
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
         always_comb
            begin
               next_state = present_state;
              case(present_state)
                 IDLE: begin
                         if(arvalid && arready)
                           begin
                             next_state = READ_DATA;
                           end
                        end

                 READ_DATA : begin
                                 if(count_done)
                                      begin
                                           next_state = IDLE;
                                      end
                                      else if(!rready)
                                        
                                         begin
                                           next_state = WAIT_ACK;
                                         end
                                      else
                                          begin
                                            next_state = READ_DATA;
                                          end
                               end
                 WAIT_ACK : begin
                              if(rready)
                                  begin
                                    next_state = READ_DATA;
                                  end
                             end
                                                      
                  
            endcase
       end

//======================BURST COUNTER LOGIC=================================
  always_ff @(posedge clk or negedge rst)
       begin
          if(!rst)
            begin
                burst_count <= 0;
            end
          else if(present_state == IDLE && arvalid && arready)
            begin
                 burst_count <= burst_length;   ///////initialize burst counter on address handshake
            end
          else if(present_state == READ_DATA && count_en)
            begin
                if(burst_count > 0)
            begin
                    burst_count <= burst_count - 1; ////decrement burst counter
            end
            end
       end

//======================COUNTER DONE LOGIC=================================
always_ff @(posedge clk or negedge rst)
          begin
            if(!rst)
               begin
                  count_done <= 0;
               end
            else if(burst_count == 1 && present_state == READ_DATA)
               begin
                  count_done <= 1;   //////signal burst completion
               end 
            else if(present_state == IDLE)
               begin
                   count_done <= 0;   /////reset count_done in IDLE state
               end
           end

//======================COUNTER LOGIC=================================
     always_ff @(posedge clk or negedge rst)
       begin
         if(!rst)
             begin
               counter <= 0;
               rdata <= 0;
             end
         else if(count_en)
             begin
                counter <= counter + 1;  ////increment counter when enabled
                rdata <= data_in;
             end
         else 
             begin
                 counter <= 0;   /////reset counter otherwise
                 rdata <=0;
             end
    end

           
//======================COUNTER ENABLE LOGIC=================================
    always_ff @(posedge clk or negedge rst)
       begin
         if(!rst)
              begin
                count_en <= 0;
               end
        else if( present_state == READ_DATA && rready)   //// && (rdata == shared_memory))
              begin
                 count_en <= 1;    ////enable counter in DATA_STATE when wready is high
              end 
        else 
              begin
                 count_en <= 0;    /////disable counter otherwise
              end
     end

//======================OUTPUT LOGIC=================================
  always_ff @(posedge clk or negedge rst)
    begin
      if(!rst)
          begin
             rvalid <= 0;
             rid    <= 0;
             rresp  <= 2'b0;
             //rdata  <= ;
             rlast  <= 0;


          end
       else
          begin
         // rvalid <= 1'b1;
      case(present_state)
         IDLE: begin
         if(arvalid && arready)
             rvalid <= 1'b1;
               if(burst_count > 0)
                        begin
                         rvalid <= 1'b1;
                         end
                         else
                             begin
                             rvalid = 0;
                             end 
               end

         READ_DATA : begin
                         rvalid <= 1'b1;
                         if(rready)
                             begin
                             rlast <= (burst_count ==1);
                             rid <= $random;
                             rresp <= $random;
                                     case(rresp)
                                            2'b00   : response_string = "OKAY";
                                            2'b01   : response_string = "EXOKAY";
                                            2'b10   : response_string = "SLVERR";
                                            default : response_string = "UNKNOWN";
                                     endcase

                             end
                     end

         WAIT_ACK : begin
                           rvalid <= 1'b0;
                     end

         default : begin
                            rvalid   <= 1'b0;
                            rlast    <= 0;
                   end
      endcase
    end 
  end
   
endmodule
