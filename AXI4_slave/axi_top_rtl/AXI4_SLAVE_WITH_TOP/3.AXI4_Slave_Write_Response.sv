module axi4_slave_write_response 
#(
//=========================PARAMETERS=============================
         parameter ID_WIDTH = 4
)(
//=========================INPUT SIGNALS===========================
         input      logic                           clk,
         input      logic                           rst,
         input      logic                           bready,  /////master ready to accept the response
         input      logic                           wlast,   ////write last signal
         input      logic    [ID_WIDTH-1:0]   stored_awid_in,
         
//=========================OUTPUT SIGNALS==========================
         output     logic    [ID_WIDTH - 1 : 0 ]    bid,     //////response id
         output     logic    [1:0]                  bresp,   /////write response
         output     logic                           bvalid  //////slave indicates response is valid
);

//=========================FSM STATES==============================

         typedef enum logic [1:0] {
                                    IDLE            = 2'b00,
                                    READ_RESPONSE   = 2'b01
                                  } FMS_STATE;
         FMS_STATE present_state,next_state;

//===========================INTERNAL REGISTERS======================
 string response_string;
 
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
                          if(wlast)
                              begin
                                next_state = READ_RESPONSE;
                              end
                          else
                              begin
                                next_state = IDLE;
                              end
                              
                        end

                READ_RESPONSE : begin
                                  if(bready)
                                     begin
                                            next_state = READ_RESPONSE;  //transition back to idle after response
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
              bvalid <= 0;
              bid <=0;
              bresp <= 0;
            end
            else
             begin
             case(present_state)
                IDLE : begin
                          if(wlast)
                           begin
                            bvalid <= 1'b1; ///ready to accept response
                            
                           end
                       end

                READ_RESPONSE : begin
                                   bvalid <= 1'b0; ///assert bready to indicate readiness 
                                 if(bready)
                                  begin
                                    // bvalid <= 1'b0; ///stop readiness after receiving response
                                     bid <= stored_awid_in;
                                     bresp <= $random;
                                     case(bresp)
                                            2'b00   : response_string = "OKAY";
                                            2'b01   : response_string = "EXOKAY";
                                            2'b10   : response_string = "SLVERR";
                                            default : response_string = "UNKNOWN";
                                     endcase
                                  end
                                 else
                                   begin
                                     bvalid <= 1'b0;
                                   end
                                end
             endcase
           end
       end

endmodule
